//
//  MasterViewController+StoreSubscriber.swift
//  MacKey
//
//  Created by Liu Liang on 15/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import UIKit
import SimpleTouch
import Result
import ReSwift

extension MasterViewController: StoreSubscriber {
    func newState(state: HostsState?) {
        guard let state = state else { return }
        if let newHost = state.newHost {
            newStateWithNewHost(newHost, state: state)
        }
        if let removedHost = state.removedHost {
            newStateWithRemovedHost(removedHost, state: state)
        }
        if state.hostsUpdated {
            newStateWithUpdatedHost(state: state)
        }
        if state.hostSelected {
            wakeUpAndRequireTouchID()
        }
    }

    private func newStateWithNewHost(_ newHost: HostInfo, state: HostsState) {
        let index = store.state.sortedHostAliases.binarySearch{$0 < newHost.alias}
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    private func newStateWithRemovedHost(_ removedHost: HostInfo, state: HostsState) {
        var indexPathToRemove: IndexPath? = nil
        self.tableView.visibleCells.forEach { cell in
            if let hostAlias = cell.textLabel?.text, hostAlias == removedHost.alias {
                indexPathToRemove = self.tableView.indexPath(for: cell)
            }
        }
        
        if let indexPath = indexPathToRemove {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    private func newStateWithUpdatedHost(state: HostsState) {
        if (!state.hostAdded && !state.hostRemoved) {
            self.tableView.reloadData()
        }
        MacHostsInfoService().saveMacHostsInfo(hosts: state.allHosts)
    }
}
