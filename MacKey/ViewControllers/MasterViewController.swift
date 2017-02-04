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

    var selectedCell: UITableViewCell? = nil
    var latestHostUnlockStatus: String? = nil
    
    private let disposeBag = DisposeBag()
    
    fileprivate var latestState: State {
        return store.observable.value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let editButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
        editButtonItem.rx.tap.subscribe(onNext: { [unowned self] in
            self.editCell(self.selectedCell)
        }).disposed(by: disposeBag)
        self.navigationItem.leftBarButtonItem = editButtonItem
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.rx.tap.subscribe(onNext: {
            UIApplication.shared.openURL(URL(string: readMeURL)!)
        }).disposed(by: disposeBag)
        let infoItem = UIBarButtonItem(customView: infoButton)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        addButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.showHostDetaisViewController(animated: true)
        }).disposed(by: disposeBag)
        self.navigationItem.rightBarButtonItems = [addButton, infoItem]
                
        // Hide empty rows
        tableView.tableFooterView = UIView()
        
        let viewModel = MasterViewModel(itemSelected: tableView.rx.itemSelected.asDriver())

        viewModel.stateDiff.drive(onNext: { [unowned self] (prevState: HostsState, state: HostsState) -> () in
            let newHost = HostsState.newHostAfter(prevState.allHosts, in: state.allHosts)
            if let newHost = newHost, let index = state.sortedHostAliases.index(of: newHost.alias) {
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
            }
            let removedHost = HostsState.removedHostFrom(prevState.allHosts, in: state.allHosts)
            if let removedHost = removedHost {
                var indexPathToRemove: IndexPath? = nil
                self.tableView.visibleCells.forEach { cell in
                    if let hostAlias = cell.textLabel?.text, hostAlias == removedHost.alias {
                        indexPathToRemove = self.tableView.indexPath(for: cell)
                    }
                }
                
                if let indexPath = indexPathToRemove {
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
            if newHost == nil && removedHost == nil {
                self.tableView.reloadData()
            }
            }).disposed(by: disposeBag)
        
        viewModel.selectedIndex.drive(onNext: { [unowned self] (indexPath, hostsState) in
            self.tableView.deselectRow(at: indexPath, animated: true)
            let alias = hostsState.sortedHostAliases[indexPath.row]
            guard let host = hostsState.allHosts[alias] else { return }
            store.dispatch(SelectHost(host: host))
            
            self.latestHostUnlockStatus = ""
            self.selectedCell?.detailTextLabel?.text = ""
            
            if let cell = self.tableView.cellForRow(at: indexPath) {
                self.updateSelectCell(cell)
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
        if let selectedCell = self.selectedCell {
            if let seletedCellIndex = self.tableView.indexPath(for: selectedCell) {
                self.tableView.reloadRows(at: [seletedCellIndex], with: .none)
            }
        }
    }
    
    fileprivate func editCell(_ cell: UITableViewCell?) {
        guard let cell = cell else { return }
        let hostAlias = cell.textLabel?.text
        guard let alias = hostAlias else {
            print("hostAlias is nil")
            return
        }
        
        store.dispatch(EditHost(alias: alias))
        showHostDetaisViewController(animated: true)
    }
    
    fileprivate func updateSelectCell(_ newSelectedCell: UITableViewCell) {
        if newSelectedCell != selectedCell {
            selectedCell?.accessoryType = .none
            selectedCell?.detailTextLabel?.text = ""
            selectedCell = newSelectedCell
            newSelectedCell.accessoryType = .checkmark
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let object = latestState.hostsState.sortedHostAliases[indexPath.row]
        cell.textLabel!.text = object
        if object == latestState.latestHostAlias {
            updateSelectCell(cell)
            cell.detailTextLabel?.text = latestHostUnlockStatus
        } else {
            cell.detailTextLabel?.text = ""
        }
        return cell
    }
}

extension MasterViewController { // UITableViewDelegate
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit", handler:{action, indexpath in
            tableView.setEditing(false, animated: true)
            self.editCell(tableView.cellForRow(at: indexPath))
        });
        
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler:{action, indexpath in
            let cell = tableView.cellForRow(at: indexPath)
            guard let hostAlias = cell?.textLabel?.text else {
                print("hostAlias is nil")
                return
            }
            guard let host = store.observable.value.allHosts[hostAlias] else { return }
            store.dispatch(RemoveHost(host: host))
        });
        
        return [deleteRowAction, editRowAction]
    }
}
