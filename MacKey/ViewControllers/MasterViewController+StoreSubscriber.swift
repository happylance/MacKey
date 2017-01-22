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
    func newState(state newState: HostsState?) {
        guard let state = newState, let cachedHosts = cachedHostsState?.allHosts else {
            cachedHostsState = newState
            return
        }
        
        let newHost = state.newHostAfter(cachedHosts)
        if let newHost = newHost {
            newStateWithNewHost(newHost, state: state)
        }
        let removedHost = state.removedHostFrom(cachedHosts)
        if let removedHost = removedHost {
            newStateWithRemovedHost(removedHost, state: state)
        }
        if state.allHosts != cachedHosts && newHost == nil && removedHost == nil {
            self.tableView.reloadData()
        }
        if state.hostSelected {
            wakeUpAndRequireTouchID()
        }
        cachedHostsState = newState
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
}
