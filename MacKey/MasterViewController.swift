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

class MasterViewController: UITableViewController {

    var selectedCell: UITableViewCell? = nil
    var latestHostUnlockStatus: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        let host = MacHost()
        host.requireLoginInfo { (didGetLoginInfo) in
            if (didGetLoginInfo) {
                let hostAliases = self.hostAliases()
                let index = hostAliases.binarySearch{$0 < host.alias}
                
                MacHostsManager.sharedInstance.hosts[host.alias] = host
                MacHostsManager.sharedInstance.saveHosts()
                
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MacHostsManager.sharedInstance.hosts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let alias = self.hostAliases()[indexPath.row]
        MacHostsManager.sharedInstance.latestHostAlias = alias
        requireTouchID()
        
        latestHostUnlockStatus = ""
        self.selectedCell?.detailTextLabel?.text = ""
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            updateSelectCell(cell)
        }
        
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let editRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Edit", handler:{action, indexpath in
            tableView.setEditing(false, animated: true)
            
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            let hostAlias = cell?.textLabel?.text
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

        });
        
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler:{action, indexpath in
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            let hostAlias = cell?.textLabel?.text
            if hostAlias == nil {
                print("hostAlias is nil")
                return
            }
            MacHostsManager.sharedInstance.hosts.removeValueForKey(hostAlias!)
            MacHostsManager.sharedInstance.saveHosts()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        });
        
        return [deleteRowAction, editRowAction]
    }
    
    func hostAliases() -> [String] {
        return MacHostsManager.sharedInstance.hosts.keys.sort()
    }
    
    func updateSelectCell(newSelectedCell: UITableViewCell) {
        if newSelectedCell != selectedCell {
            selectedCell?.accessoryType = .None
            selectedCell?.detailTextLabel?.text = ""
            selectedCell = newSelectedCell
            newSelectedCell.accessoryType = .Checkmark
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
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let result = macHost.executeCmd(cmd)
                dispatch_async(dispatch_get_main_queue(), {
                    let latestHostAlias = MacHostsManager.sharedInstance.latestHostAlias
                    if macHost.alias != latestHostAlias {
                        print("Ignore the result of '\(cmd)' for '\(macHost.alias)' because the latest host now is '\(latestHostAlias)'")
                        return
                    }
                    
                    switch result {
                    case .Success:
                        self.setDetailLabel("\(result.value!)")
                    case .Failure:
                        self.setDetailLabel("\(result.error?.localizedDescription ?? "")")
                    }
                })
            })
        }
    }
    
    func setDetailLabel(string: String) {
        latestHostUnlockStatus = string
        if let selectedCell = self.selectedCell {
            if let seletedCellIndex = self.tableView.indexPathForCell(selectedCell) {
                self.tableView.reloadRowsAtIndexPaths([seletedCellIndex], withRowAnimation: .None)
            }
        }
    }
    
    func handleTouchIDResult(result: Result<Bool, TouchIDError>) {
        switch(result) {
        case .Success:
            self.unlockHostAndConfigureView()
        case .Failure:
            self.setDetailLabel(TouchIDUtils.getErrorMessage(result.error!))
        }
    }
    
    func clearUnlockStatus() {
        setDetailLabel("")
    }

}

