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

    var selectedCell: HostListViewCell? = nil
    var latestHostUnlockStatus: String? = nil
    let sleepButtonTapped: PublishSubject<String> = PublishSubject()
    let editCell: PublishSubject<HostListViewCell> = PublishSubject()
    let deleteCell: PublishSubject<HostListViewCell> = PublishSubject()
    
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate var latestState: State {
        return store.observable.value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let editButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
        editButtonItem.rx.tap.subscribe(onNext: { [unowned self] in
            if let selectedCell = self.selectedCell {
                self.editCell.onNext(selectedCell)
            }
        }).disposed(by: disposeBag)
        self.navigationItem.leftBarButtonItem = editButtonItem
        
        self.editCell.subscribe(onNext: { [unowned self] in
            self.editCell($0)
        }).disposed(by: disposeBag)
        
        self.deleteCell.subscribe(onNext: {[unowned self] in
            self.deleteCell($0)
        }).disposed(by: disposeBag)
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.rx.tap.subscribe(onNext: {
            UIApplication.shared.openURL(URL(string: readMeURL)!)
        }).disposed(by: disposeBag)
        let infoItem = UIBarButtonItem(customView: infoButton)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        addButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.showHostDetailsViewController(animated: true)
        }).disposed(by: disposeBag)
        self.navigationItem.rightBarButtonItems = [addButton, infoItem]
                
        // Hide empty rows
        tableView.tableFooterView = UIView()
        
        let viewModel = MasterViewModel(
            itemSelected: tableView.rx.itemSelected.asDriver(),
            sleepButtonTapped: sleepButtonTapped.asDriver(onErrorJustReturn:"")
            )

        viewModel.stateDiff.drive(onNext: { [unowned self] (prevState: HostsState, state: HostsState) -> () in
            let newHost = HostsState.newHostAfter(prevState.allHosts, in: state.allHosts)
            if let newHost = newHost, let index = state.sortedHostAliases.index(of: newHost.alias) {
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
            }
            let removedHost = HostsState.removedHostFrom(prevState.allHosts, in: state.allHosts)
        
            if newHost == nil && removedHost == nil {
                self.tableView.reloadData()
            }
            }).disposed(by: disposeBag)
        
        viewModel.selectedIndex.drive(onNext: { [unowned self] (indexPath, hostsState) in
            self.tableView.deselectRow(at: indexPath, animated: true)
            let alias = hostsState.sortedHostAliases[indexPath.row]
            guard let host = hostsState.allHosts[alias] else { return }
            store.dispatch(SelectHost(host: host))
            
            if let cell = self.tableView.cellForRow(at: indexPath) as? HostListViewCell {
                self.reloadCells([cell, self.selectedCell])
            }            
        }).disposed(by: disposeBag)
        
        viewModel.selectedCellStatusUpdate.drive(onNext: { [unowned self] info in
            self.setDetailLabel(info)
        }).disposed(by: disposeBag)
        
        viewModel.didEnterBackground.drive(onNext: { [unowned self] _ in
            self.setDetailLabel("")
        }).disposed(by: disposeBag)
    }
    
    private func setDetailLabel(_ string: String) {
        latestHostUnlockStatus = string
        self.reloadCells([self.selectedCell])
    }
    
    private func reloadCells(_ cells: [HostListViewCell?]) {
        let indexPathsToReload = cells
            .flatMap { $0 }
            .reduce([HostListViewCell]()) { $0.contains($1) ? $0 : $0 + [$1] } // Remove duplicates
            .flatMap { self.tableView.indexPath(for: $0) }
        self.tableView.reloadRows(at: indexPathsToReload, with: .none)
    }
    
    private func deleteCell(_ cell:HostListViewCell) {
        if let hostAlias = cell.hostNameOutlet?.text,
            let host = store.observable.value.allHosts[hostAlias] {
            store.dispatch(RemoveHost(host: host))
            if let indexPathToRemove = self.tableView.indexPath(for: cell) {
                self.tableView.deleteRows(at: [indexPathToRemove], with: .fade)
            }
        }
    }
    
    private func editCell(_ cell:HostListViewCell) {
        if let alias = cell.hostNameOutlet?.text {
            store.dispatch(EditHost(alias: alias))
            self.showHostDetailsViewController(animated: true)
        }
    }
}

extension MasterViewController  { // UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return latestState.allHosts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> HostListViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HostListViewCell", for: indexPath) as? HostListViewCell else {
            fatalError("Could not create HostListViewCell")
        }
        
        let alias = latestState.hostsState.sortedHostAliases[indexPath.row]
        cell.hostNameOutlet!.text = alias
        
        cell.sleepButtonOutlet.rx.tap.subscribe(onNext:{ [unowned self] in
            self.sleepButtonTapped.onNext(alias)
        })
        .disposed(by: disposeBag)
        
        if alias == latestState.latestHostAlias {
            cell.hostStatusOutlet?.text = latestHostUnlockStatus
            cell.sleepButtonOutlet.isHidden = !(latestHostUnlockStatus?.contains("unlocked") ?? false)
            cell.accessoryType = .checkmark
            self.selectedCell = cell
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
                self.editCell.onNext(cell)
            }
        });
        
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler:{action, indexpath in
            if let cell = tableView.cellForRow(at: indexPath) as? HostListViewCell {
                self.deleteCell.onNext(cell)
            }
        });
        
        return [deleteRowAction, editRowAction]
    }
}
