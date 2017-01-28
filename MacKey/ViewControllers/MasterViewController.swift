//
//  MasterViewController.swift
//  MacKey
//
//  Created by Liu Liang on 5/14/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import UIKit
import SimpleTouch
import Result
import ReactiveReSwift
import RxSwift

let readMeURL = "https://github.com/happylance/MacKey/blob/master/README.md"

class MasterViewController: UITableViewController {

    var selectedCell: UITableViewCell? = nil
    var latestHostUnlockStatus: String? = nil
    var cachedHostsState: HostsState?
    
    private let disposeBag = DisposeBag()
    
    fileprivate var state: State {
        return store.observable.value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let editButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
        editButtonItem.rx.tap.subscribe(onNext: { [unowned self] in
            self.editCell(self.selectedCell)
        }).addDisposableTo(disposeBag)
        self.navigationItem.leftBarButtonItem = editButtonItem
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.rx.tap.subscribe(onNext: {
            UIApplication.shared.openURL(URL(string: readMeURL)!)
        }).addDisposableTo(disposeBag)
        let infoItem = UIBarButtonItem(customView: infoButton)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        addButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.showHostDetaisViewController(animated: true)
        }).addDisposableTo(disposeBag)
        self.navigationItem.rightBarButtonItems = [addButton, infoItem]
                
        // Hide empty rows
        tableView.tableFooterView = UIView()
        
        cachedHostsState = state.hostsState
        
        store.observable.asObservable().map { $0.hostsState }
            .subscribe(onNext: { [unowned self] in
                self.newState(state: $0)
            }).addDisposableTo(disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                self.tableView.deselectRow(at: indexPath, animated: true)
                let alias = self.state.sortedHostAliases[indexPath.row]
                guard let host = self.state.allHosts[alias] else { return }
                store.dispatch(SelectHost(host: host))
                
                self.latestHostUnlockStatus = ""
                self.selectedCell?.detailTextLabel?.text = ""
                
                if let cell = self.tableView.cellForRow(at: indexPath) {
                    self.updateSelectCell(cell)
                }

            }).addDisposableTo(disposeBag)
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
        return state.allHosts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let object = state.sortedHostAliases[indexPath.row]
        cell.textLabel!.text = object
        if object == state.latestHostAlias {
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
