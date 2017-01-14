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

let readMeURL = "https://github.com/happylance/MacKey/blob/master/README.md"

class MasterViewController: UITableViewController {

    var selectedCell: UITableViewCell? = nil
    var latestHostUnlockStatus: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editSelectedCell))

        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(showInfoPage), for: .touchUpInside)
        let infoItem = UIBarButtonItem(customView: infoButton)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItems = [addButton, infoItem]
                
        // Hide empty rows
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(_ sender: AnyObject) {
        let host = MacHost()
        host.requireLoginInfo { (didGetLoginInfo) in
            if (didGetLoginInfo) {
                let hostAliases = self.hostAliases()
                let index = hostAliases.binarySearch{$0 < host.alias}
                
                MacHostsManager.sharedInstance.hosts[host.alias] = host
                MacHostsManager.sharedInstance.saveHosts()
                
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func showInfoPage() {
        UIApplication.shared.openURL(URL(string: readMeURL)!)
    }
    
    func editSelectedCell() {
        editCell(selectedCell)
    }
    
    func editCell(_ cell: UITableViewCell?) {
        guard let cell = cell else { return }
        let hostAlias = cell.textLabel?.text
        if hostAlias == nil {
            print("hostAlias is nil")
            return
        }
        let host = MacHostsManager.sharedInstance.hosts[hostAlias!]
        if host  == nil {
            print("host is nil for \(hostAlias!)")
            return
        }
        host!.requireLoginInfo { (didGetLoginInfo) in
            if (didGetLoginInfo) {
                MacHostsManager.sharedInstance.hosts[host!.alias] = host
                MacHostsManager.sharedInstance.saveHosts()
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MacHostsManager.sharedInstance.hosts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = hostAliases()[indexPath.row]
        cell.textLabel!.text = object
        if object == MacHostsManager.sharedInstance.latestHostAlias {
            updateSelectCell(cell)
            cell.detailTextLabel?.text = latestHostUnlockStatus
        } else {
            cell.detailTextLabel?.text = ""
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alias = self.hostAliases()[indexPath.row]
        MacHostsManager.sharedInstance.latestHostAlias = alias
        
        latestHostUnlockStatus = ""
        self.selectedCell?.detailTextLabel?.text = ""

        if let cell = tableView.cellForRow(at: indexPath) {
            updateSelectCell(cell)
        }
        
        wakeUpAndRequireTouchID()
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit", handler:{action, indexpath in
            tableView.setEditing(false, animated: true)
            self.editCell(tableView.cellForRow(at: indexPath))
        });
        
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler:{action, indexpath in
            let cell = tableView.cellForRow(at: indexPath)
            let hostAlias = cell?.textLabel?.text
            if hostAlias == nil {
                print("hostAlias is nil")
                return
            }
            MacHostsManager.sharedInstance.hosts.removeValue(forKey: hostAlias!)
            MacHostsManager.sharedInstance.saveHosts()
            tableView.deleteRows(at: [indexPath], with: .fade)
        });
        
        return [deleteRowAction, editRowAction]
    }
    
    func hostAliases() -> [String] {
        return MacHostsManager.sharedInstance.hosts.keys.sorted()
    }
    
    func updateSelectCell(_ newSelectedCell: UITableViewCell) {
        if newSelectedCell != selectedCell {
            selectedCell?.accessoryType = .none
            selectedCell?.detailTextLabel?.text = ""
            selectedCell = newSelectedCell
            newSelectedCell.accessoryType = .checkmark
        }
    }
    
    
    func requireTouchID() {
        TouchIDUtils.runTouchID { (result) in
            self.handleTouchIDResult(result)
        }
    }
    
    func unlockHostAndConfigureView() {
        // Update the user interface for the detail item.
        if let macHost = MacHostsManager.sharedInstance.latestHost() {
            let cmd = "unlock"
            setDetailLabel("Unlocking...")
            MacHostsManager.sharedInstance.latestHostAlias = macHost.alias
           
            DispatchQueue.global().async(execute: {
                let result = macHost.executeCmd(cmd)
                DispatchQueue.main.async(execute: {
                    let latestHostAlias = MacHostsManager.sharedInstance.latestHostAlias
                    if macHost.alias != latestHostAlias {
                        print("Ignore the result of '\(cmd)' for '\(macHost.alias)' because the latest host now is '\(latestHostAlias)'")
                        return
                    }
                    
                    switch result {
                    case .success:
                        self.setDetailLabel(result.value!)
                    case .failure:
                        self.setDetailLabel(result.error?.localizedDescription ?? "")
                    }
                })
            })
        }
    }
    
    func setDetailLabel(_ string: String) {
        latestHostUnlockStatus = string
        if let selectedCell = self.selectedCell {
            if let seletedCellIndex = self.tableView.indexPath(for: selectedCell) {
                self.tableView.reloadRows(at: [seletedCellIndex], with: .none)
            }
        }
    }
    
    func handleTouchIDResult(_ result: Result<Bool, TouchIDError>) {
        switch(result) {
        case .success:
            self.unlockHostAndConfigureView()
        case .failure:
            self.setDetailLabel(TouchIDUtils.getErrorMessage(result.error!))
        }
    }
    
    func clearUnlockStatus() {
        setDetailLabel("")
    }
    
    func wakeUpAndRequireTouchID() {
        if let macHost = MacHostsManager.sharedInstance.latestHost() {
            let cmd = "wake"
            setDetailLabel("Connecting...")
            MacHostsManager.sharedInstance.latestHostAlias = macHost.alias
            DispatchQueue.global().async(execute: {
                let result = macHost.executeCmd(cmd)
                DispatchQueue.main.async(execute: {
                    let latestHostAlias = MacHostsManager.sharedInstance.latestHostAlias
                    if macHost.alias != latestHostAlias {
                        print("Ignore the result of '\(cmd)' for '\(macHost.alias)' because the latest host now is '\(latestHostAlias)'")
                        return
                    }
                    
                    switch result {
                    case .success:
                        if result.value == "" {
                            self.setDetailLabel("Connected")
                            self.requireTouchID()
                        } else {
                            self.setDetailLabel(result.value!)
                        }
                    case .failure:
                        self.setDetailLabel(result.error?.localizedDescription ?? "")
                    }
                })
            })
        }
    }
}

