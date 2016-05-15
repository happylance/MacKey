//
//  MasterViewController.swift
//  MacKey
//
//  Created by Liu Liang on 5/14/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var selectedCell:UITableViewCell? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
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

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let alias = self.hostAliases()[indexPath.row]
                let object = MacHostsManager.sharedInstance.hosts[alias]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.macHost = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
                
                if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                    updateSelectCell(cell)
                }
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
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
            selectedCell = newSelectedCell
            newSelectedCell.accessoryType = .Checkmark
        }
    }
}

