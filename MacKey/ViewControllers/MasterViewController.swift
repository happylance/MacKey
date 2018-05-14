//
//  MasterViewController.swift
//  MacKey
//
//  Created by Liu Liang on 5/14/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension MacUnlockService: MacUnlockUseCase {}
    
class MasterViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var sleepButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var unlockButtonOutlet: UIBarButtonItem!

    fileprivate var latestHostUnlockStatus = ""
    fileprivate let editCell$: PublishSubject<String> = PublishSubject()
    fileprivate let deleteCell$: PublishSubject<String> = PublishSubject()
    
    fileprivate let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sshService = Config.forUITesting ? MockSSHService() : SSHService()
        let viewModel = MasterViewModel(macUnlockService: MacUnlockService(sshService: sshService))
        store.observable.asObservable()
            .map { $0.hostsState }
            .delay(0.1, scheduler: MainScheduler.instance)
            .bind(to: viewModel.hostsState)
            .disposed(by: disposeBag)
        
        let notificationMappings: [(NSNotification.Name, PublishRelay<()>)] =
            [(.UIApplicationWillEnterForeground, viewModel.enterForeground),
             (.UIApplicationDidEnterBackground, viewModel.enterBackground)]
        notificationMappings.forEach {
            NotificationCenter
                .default.rx.notification($0.0)
                .map { _ in }
                .bind(to: $0.1)
                .disposed(by: disposeBag)
        }
        
        setUpUnlockAction(viewModel: viewModel)
        setUpSleepAction(viewModel: viewModel)
        
        navigationItem.leftBarButtonItems = [getEditButtonItem(viewModel: viewModel),
                                             getDeleteButtonItem(viewModel: viewModel)]
        navigationItem.rightBarButtonItems = [getAddButtonItem(), getInfoButtonItem()]
        
        navigationController?.setToolbarHidden(false, animated: true)
        
        tableView.dataSource = self
                
        // Hide empty rows
        tableView.tableFooterView = UIView()
        
        navigationController?.navigationBar.accessibilityIdentifier = "Mac Key"
    }
    
    private func getDeleteButtonItem(viewModel: MasterViewModel) -> UIBarButtonItem {
        let deleteButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: nil)
        deleteButtonItem.accessibilityIdentifier = "Delete"
        let defaultColor = deleteButtonItem.tintColor
        viewModel.hasSelectedCell$
            .do(onNext: { deleteButtonItem.tintColor = $0 ? defaultColor : UIColor.gray })
            .bind(to: deleteButtonItem.rx.isEnabled)
            .disposed(by: disposeBag)
        
        deleteButtonItem.rx.tap
            .withLatestFrom(store.observable.asObservable()) { ($0, $1.hostsState.latestHostAlias) }
            .subscribe(onNext: { [unowned self] (_, latestHostAlias) in
                let selectedAlias = latestHostAlias
                if selectedAlias.count > 0 {
                    self.deleteCell$.onNext(selectedAlias)
                }
            }).disposed(by: disposeBag)
        
        self.deleteCell$
            .withLatestFrom(store.observable.asObservable()) { ($0, $1.hostsState) }
            .subscribe(onNext: {[unowned self] (alias, hostsState) in
            if let host = hostsState.allHosts[alias],
                let index = hostsState.sortedHostAliases.index(of: alias) {
                let alertView = UIAlertController(title: String(format:"Delete '%@'".localized(), alias),
                    message: String(format:"Are you sure that you want to delete '%@'?".localized(), "\(alias): \(host.user)@\(host.host)"),
                    preferredStyle: .alert)
                let deleteAction = UIAlertAction(title: "Delete".localized(), style: .destructive) { _ in
                    store.dispatch(RemoveHost(host: host))
                    let indexPathToRemove = IndexPath(row: index, section: 0)
                    self.tableView.deleteRows(at: [indexPathToRemove], with: .fade)
                }
                let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel) { _ in }
                alertView.addAction(deleteAction)
                alertView.addAction(cancelAction)
                alertView.view.accessibilityIdentifier = "Delete"
                self.present(alertView, animated: true) {
                    let deleteButton = deleteAction.value(forKey: "__representer") as? UIView
                    deleteButton?.accessibilityIdentifier = "Delete"
                }
            }
        }).disposed(by: disposeBag)
        return deleteButtonItem
    }
    
    private func getEditButtonItem(viewModel: MasterViewModel) -> UIBarButtonItem {
        let editButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
        editButtonItem.accessibilityIdentifier = "Edit"
        let defaultColor = editButtonItem.tintColor
        viewModel.hasSelectedCell$
            .do(onNext: { editButtonItem.tintColor = $0 ? defaultColor : UIColor.gray })
            .bind(to: editButtonItem.rx.isEnabled)
            .disposed(by: disposeBag)
        
        editButtonItem.rx.tap
            .withLatestFrom(store.observable.asObservable()) { ($0, $1.hostsState.latestHostAlias) }
            .subscribe(onNext: { [unowned self] (_, latestHostAlias) in
            let selectedAlias = latestHostAlias
            if selectedAlias.count > 0 {
                self.editCell$.onNext(selectedAlias)
            }
        }).disposed(by: disposeBag)
        
        self.editCell$
            .withLatestFrom(store.observable) { ($0, $1) }
            .flatMapFirst { (alias, state) -> Maybe<(HostInfo, HostInfo?)> in
                let allHosts = state.hostsState.allHosts
                if let oldHost = allHosts[alias],
                    let hostDetailVC = self.showHostDetailsViewController(animated: true, forNewHost: false) {
                    let hostState = HostDetailsViewState(hostInfo: oldHost, allHostKeys: Array(allHosts.keys), supportSkippingTouchID: state.supportSkippingTouchID)
                    let hostDetailViewModel = HostDetailsViewModel(initialState: hostState)
                    hostDetailVC.viewModel = hostDetailViewModel
                    
                    return hostDetailViewModel.dismiss$.map { (oldHost, $0) }.asObservable().asMaybe()
                }
                return .empty()
            }
            .subscribe(onNext: { (oldHost, hostInfo) in
                if let newHost = hostInfo {
                    store.dispatch(UpdateHost(oldHost: oldHost, newHost: newHost))
                    self.tableView.reloadData()
                }
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        return editButtonItem
    }
    
    private func setUpSleepAction(viewModel: MasterViewModel) {
        let defaultColor = sleepButtonOutlet.tintColor
        viewModel.selectedCellStatusUpdate$
            .map { $0.contains("unlocked") }
            .startWith(false)
            .do(onNext: {[unowned self] in self.sleepButtonOutlet.tintColor = $0 ? defaultColor : UIColor.gray })
            .bind(to: sleepButtonOutlet.rx.isEnabled)
            .disposed(by: disposeBag)
        
        sleepButtonOutlet.rx.tap
            .withLatestFrom(store.observable.asObservable()) { $1.hostsState.latestHostAlias }
            .flatMapFirst { alias -> Observable<String> in
                if (store.value.supportSleepMode) {
                    return Observable.just(alias)
                } else if let upgradeViewController = self.showUpgradeViewController(
                    animated: true, forProductType: .sleepMode) {
                    return upgradeViewController.getPurchaseState$()
                        .filter { $0 == .purchased }
                        .map {_ in alias }
                }
                return Observable.empty()
            }
            .bind(to: viewModel.sleepRequests)
            .disposed(by: disposeBag)
    }
    
    private func setUpUnlockAction(viewModel: MasterViewModel) {
        viewModel.selectedIndex$
            .subscribe(onNext: { [unowned self] (indexPath, hostsState) in
            self.tableView.deselectRow(at: indexPath, animated: true)
            let alias = hostsState.sortedHostAliases[indexPath.row]
            guard let host = hostsState.allHosts[alias] else { return }
            let previousSelectedAlias = hostsState.latestHostAlias
            store.dispatch(SelectHost(host: host))
            
            self.reloadCells([alias, previousSelectedAlias])
            
        }).disposed(by: disposeBag)
        
        viewModel.selectedCellStatusUpdate$
            .withLatestFrom(store.asDriver()) { ($0, $1.hostsState.latestHostAlias) }
            .subscribe(onNext: { [unowned self] (info, latestHostAlias) in
            self.latestHostUnlockStatus = info
            self.reloadCells([latestHostAlias])
        }).disposed(by: disposeBag)
        
        let defaultColor = unlockButtonOutlet.tintColor
        viewModel.hasSelectedCell$
            .do(onNext: {[unowned self] in self.unlockButtonOutlet.tintColor = $0 ? defaultColor : UIColor.gray })
            .bind(to: unlockButtonOutlet.rx.isEnabled)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected.bind(to: viewModel.unlockRequest).disposed(by: disposeBag)
        unlockButtonOutlet.rx.tap
            .withLatestFrom(store.observable.asObservable()) { $1.hostsState }
            .map { $0.sortedHostAliases.index(of: $0.latestHostAlias) }
            .filter { $0 != nil }.map { $0! }
            .map { IndexPath(row: $0, section: 0) }
            .bind(to: viewModel.unlockRequest)
            .disposed(by: disposeBag)
    }
    
    private func getAddButtonItem() -> UIBarButtonItem {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        addButton.accessibilityIdentifier = "Add"
        addButton.rx.tap
            .withLatestFrom(store.observable)
            .flatMapFirst { state -> Single<HostInfo?> in
                if let hostDetailVC = self.showHostDetailsViewController(animated: true, forNewHost: true) {
                    let hostState = HostDetailsViewState(hostInfo: HostInfo(), allHostKeys: Array(state.hostsState.allHosts.keys), supportSkippingTouchID: state.supportSkippingTouchID)
                    let hostDetailViewModel = HostDetailsViewModel(initialState: hostState)
                    hostDetailVC.viewModel = hostDetailViewModel
                    return hostDetailViewModel.dismiss$.asSingle()
                }
                return .just(nil)
            }
            .flatMapFirst { hostInfo -> Observable<HostInfo> in
                return Observable.create { observer in
                    self.dismiss(animated: true) {
                        if let newHost = hostInfo {
                            store.dispatch(AddHost(host: newHost))
                            observer.onNext(newHost)
                        }
                        observer.onCompleted()
                    }
                    return Disposables.create()
                }
            }
            .withLatestFrom(store.observable.asObservable()) { ($0, $1.hostsState) }
            .subscribe(onNext: { [unowned self] (newHost, hostsState) in
                let index = hostsState.sortedHostAliases.index(of: newHost.alias) ?? 0
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
            })
            .disposed(by: disposeBag)
        return addButton
    }
    
    private func getInfoButtonItem() -> UIBarButtonItem {
        let infoButton = UIBarButtonItem(title: "Help".localized(), style: .plain, target: nil, action: nil)
        infoButton.accessibilityIdentifier = "HelpButton"
        infoButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.showHelpViewController(animated: true)
        }).disposed(by: disposeBag)
        return infoButton
    }
    
    private func reloadCells(_ aliases: [String]) {
        let indexPathsToReload = aliases
            .filter { $0.count > 0 }
            .compactMap { store.hostsState.sortedHostAliases.index(of: $0) }
            .reduce([Int]()) { $0.contains($1) ? $0 : $0 + [$1] } // Remove duplicates
            .map { IndexPath(row: $0, section: 0) }
        self.tableView.reloadRows(at: indexPathsToReload, with: .none)
    }
}

extension MasterViewController: UITableViewDataSource  {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.hostsState.allHosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HostListViewCell", for: indexPath) as? HostListViewCell else {
            fatalError("Could not create HostListViewCell")
        }
        
        let alias = store.hostsState.sortedHostAliases[indexPath.row]
        cell.hostAliasOutlet?.text = alias
        
        if alias == store.hostsState.latestHostAlias {
            cell.hostStatusOutlet?.text = latestHostUnlockStatus.localized()
            cell.accessoryType = .checkmark
        } else {
            cell.hostStatusOutlet?.text = ""
            cell.accessoryType = .none
        }
        
        return cell
    }
}

extension MasterViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit".localized(), handler:{action, indexpath in
            tableView.setEditing(false, animated: true)
            if let cell = tableView.cellForRow(at: indexPath) as? HostListViewCell {
                self.editCell$.onNext(cell.hostAliasOutlet.text ?? "")
            }
        });
        
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler:{action, indexpath in
            if let cell = tableView.cellForRow(at: indexPath) as? HostListViewCell {
                self.deleteCell$.onNext(cell.hostAliasOutlet.text ?? "")
            }
        });
        
        return [deleteRowAction, editRowAction]
    }
}

extension Store {
    var hostsState : HostsState {
        return store.value.hostsState
    }
}
