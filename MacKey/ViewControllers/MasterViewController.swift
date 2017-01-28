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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editSelectedCell))

        
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
    }

    func editSelectedCell() {
        editCell(selectedCell)
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
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
}

extension MasterViewController { // UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alias = state.sortedHostAliases[indexPath.row]
        guard let host = state.allHosts[alias] else { return }
        store.dispatch(SelectHost(host: host))
        
        latestHostUnlockStatus = ""
        self.selectedCell?.detailTextLabel?.text = ""
        
        if let cell = tableView.cellForRow(at: indexPath) {
            updateSelectCell(cell)
        }
    }
    
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
