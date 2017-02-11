//
//  MasterViewController.swift
//  MacKey
//
//  Created by Liu Liang on 5/14/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import UIKit
import ReactiveReSwift
import RxSwift
import RxCocoa

let readMeURL = "https://github.com/happylance/MacKey/blob/master/README.md"

class MasterViewController: UITableViewController {

    fileprivate var latestHostUnlockStatus: String? = nil
    fileprivate let sleepButtonTapped$: PublishSubject<String> = PublishSubject()
    fileprivate let editCell$: PublishSubject<String> = PublishSubject()
    fileprivate let deleteCell$: PublishSubject<HostListViewCell> = PublishSubject()
    
    fileprivate let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpDeleteAction()
        setUpEditAction()
        setUpSelectAction()
        
        self.navigationItem.rightBarButtonItems = [getAddButtonItem(), getInfoButtonItem()]
                
        // Hide empty rows
        tableView.tableFooterView = UIView()
    }
    
    private func setUpDeleteAction() {
        self.deleteCell$
            .withLatestFrom(store.observable.asObservable()) { ($0, $1.hostsState.allHosts) }
            .subscribe(onNext: {[unowned self] (cell, allHosts) in
            if let hostAlias = cell.hostAliasOutlet?.text,
                let host = allHosts[hostAlias] {
                store.dispatch(RemoveHost(host: host))
                if let indexPathToRemove = self.tableView.indexPath(for: cell) {
                    self.tableView.deleteRows(at: [indexPathToRemove], with: .fade)
                }
            }
        }).disposed(by: disposeBag)
    }
    
    private func setUpEditAction() {
        let editButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
        editButtonItem.rx.tap
            .withLatestFrom(store.observable.asObservable()) { ($0, $1.hostsState.latestHostAlias) }
            .subscribe(onNext: { [unowned self] (_, latestHostAlias) in
            let selectedAlias = latestHostAlias
            if selectedAlias.characters.count > 0 {
                self.editCell$.onNext(selectedAlias)
            }
        }).disposed(by: disposeBag)
        self.navigationItem.leftBarButtonItem = editButtonItem
        
        self.editCell$
            .withLatestFrom(store.observable.asObservable()) { ($0, $1.hostsState.allHosts) }
            .flatMapFirst { (alias, allHosts) -> Observable<(HostInfo, EditHostState)> in
                if let oldHost = allHosts[alias],
                    let hostDetailVC = self.showHostDetailsViewController(animated: true, forNewHost: false) {
                    hostDetailVC.oldHost = oldHost
                    return hostDetailVC.getEditHostState().map { (oldHost, $0) }
                }
                return Observable.empty()
            }
            .subscribe(onNext: { (oldHost, editHostState) in
                switch editHostState {
                case let .saved(newHost):
                    store.dispatch(UpdateHost(oldHost: oldHost, newHost: newHost))
                    self.tableView.reloadData()
                default: break
                }
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func setUpSelectAction() {
        let viewModel = MasterViewModel(
            itemSelected$: tableView.rx.itemSelected.asDriver(),
            sleepButtonTapped$: sleepButtonTapped$.asDriver(onErrorJustReturn:"")
        )
        
        viewModel.selectedIndex$
            .drive(onNext: { [unowned self] (indexPath, hostsState) in
            self.tableView.deselectRow(at: indexPath, animated: true)
            let alias = hostsState.sortedHostAliases[indexPath.row]
            guard let host = hostsState.allHosts[alias] else { return }
            let previousSelectedAlias = hostsState.latestHostAlias
            store.dispatch(SelectHost(host: host))
            
            self.reloadCells([alias, previousSelectedAlias])
            
        }).disposed(by: disposeBag)
        
        viewModel.selectedCellStatusUpdate$
            .withLatestFrom(store.observable.asDriver()) { ($0, $1.hostsState.latestHostAlias) }
            .drive(onNext: { [unowned self] (info, latestHostAlias) in
            self.latestHostUnlockStatus = info
            self.reloadCells([latestHostAlias])
        }).disposed(by: disposeBag)
    }
    
    private func getAddButtonItem() -> UIBarButtonItem {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        addButton.rx.tap
            .flatMapFirst { _ -> Observable<EditHostState> in
                if let hostDetailVC = self.showHostDetailsViewController(animated: true, forNewHost: true) {
                    return hostDetailVC.getEditHostState()
                }
                return Observable.empty()
            }
            .withLatestFrom(store.observable.asObservable()) { ($0, $1.hostsState) }
            .subscribe(onNext: { [unowned self] (editHostState, hostsState) in
                self.dismiss(animated: true) {
                    switch editHostState {
                    case let .saved(newHost):
                        store.dispatch(AddHost(host: newHost))
                        let index = hostsState.sortedHostAliases.index(of: newHost.alias) ?? 0
                        let indexPath = IndexPath(row: index, section: 0)
                        self.tableView.insertRows(at: [indexPath], with: .automatic)
                    default:
                        break
                    }
                }
            })
            .disposed(by: disposeBag)
        return addButton
    }
    
    private func getInfoButtonItem() -> UIBarButtonItem {
        let infoButton = UIButton(type: .infoLight)
        infoButton.rx.tap.subscribe(onNext: {
            UIApplication.shared.openURL(URL(string: readMeURL)!)
        }).disposed(by: disposeBag)
        return UIBarButtonItem(customView: infoButton)
    }
    
    private func reloadCells(_ aliases: [String]) {
        let indexPathsToReload = aliases
            .filter { $0.characters.count > 0 }
            .flatMap { store.hostsState.sortedHostAliases.index(of: $0) }
            .reduce([Int]()) { $0.contains($1) ? $0 : $0 + [$1] } // Remove duplicates
            .map { IndexPath(row: $0, section: 0) }
        self.tableView.reloadRows(at: indexPathsToReload, with: .none)
    }
}

extension MasterViewController  { // UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.hostsState.allHosts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> HostListViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HostListViewCell", for: indexPath) as? HostListViewCell else {
            fatalError("Could not create HostListViewCell")
        }
        
        let alias = store.hostsState.sortedHostAliases[indexPath.row]
        cell.hostAliasOutlet?.text = alias
        
        cell.sleepButtonOutlet.rx.tap.subscribe(onNext:{ [unowned self] in
            self.sleepButtonTapped$.onNext(alias)
        })
        .disposed(by: disposeBag)
        
        if alias == store.hostsState.latestHostAlias {
            cell.hostStatusOutlet?.text = latestHostUnlockStatus
            cell.sleepButtonOutlet.isHidden = !(latestHostUnlockStatus?.contains("unlocked") ?? false)
            cell.accessoryType = .checkmark
        } else {
            cell.hostStatusOutlet?.text = ""
            cell.sleepButtonOutlet.isHidden = true
            cell.accessoryType = .none
        }
        return cell
    }
}

extension MasterViewController { // UITableViewDelegate
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit", handler:{action, indexpath in
            tableView.setEditing(false, animated: true)
            if let cell = tableView.cellForRow(at: indexPath) as? HostListViewCell {
                self.editCell$.onNext(cell.hostAliasOutlet.text ?? "")
            }
        });
        
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler:{action, indexpath in
            if let cell = tableView.cellForRow(at: indexPath) as? HostListViewCell {
                self.deleteCell$.onNext(cell)
            }
        });
        
        return [deleteRowAction, editRowAction]
    }
}
