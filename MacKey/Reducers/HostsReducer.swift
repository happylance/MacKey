//
//  HostsReducer.swift
//  MacKey
//
//  Created by Liu Liang on 14/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import ReSwift
import ReSwiftRouter

struct HostsReducer {
    static func handleAction(_ action: Action, state: HostsState?) -> HostsState {
        let state = state ?? initialHostsState()
        print(state)
        print(action)
        return HostsState(
            allHosts: allHostsReducer(action, state: state),
            editingHostAlias: editingHostAliasReducer(action, state: state),
            hostAdded: action is AddHost,
            hostRemoved: action is RemoveHost,
            hostSelected: action is SelectHost,
            hostsUpdated: hostsUpdatedReducer(action, state: state),
            latestHostAlias: latestHostAliasReducer(action, state: state),
            newHost: (action as? AddHost)?.host,
            removedHost: (action as? RemoveHost)?.host
        )
    }
    
    private static func allHostsReducer(_ action: Action, state: HostsState) -> Hosts {
        var hosts = state.allHosts
        switch action {
        case let action as AddHost:
            let newHost = action.host
            hosts[newHost.alias] = newHost
        case let action as RemoveHost:
            let oldHost = action.host
            hosts.removeValue(forKey: oldHost.alias)
        case let action as UpdateHost where hostsUpdatedReducer(action, state: state):
            let updatedHost = action.newHost
            let oldHost = action.oldHost
            if updatedHost.alias != oldHost.alias {
                hosts.removeValue(forKey: oldHost.alias)
            }
            hosts[updatedHost.alias] = updatedHost
        default:
            break
        }
        
        return hosts
    }
    
    private static func editingHostAliasReducer(_ action: Action, state: HostsState) -> String? {
        switch action {
        case let action as EditHost:
            return action.alias
        case _ as CancelHostDetails:
            return nil
        case _ as UpdateHost:
            return nil
        default:
            break
        }
        
        return state.editingHostAlias
    }
    
    private static func hostsUpdatedReducer(_ action: Action, state: HostsState) -> Bool {
        switch action {
        case is AddHost:
            return true
        case is RemoveHost:
            return true
        case let action as UpdateHost:
            let newHost = action.newHost
            let oldHost = action.oldHost
            if newHost.alias != oldHost.alias, state.allHosts.keys.contains(newHost.alias) {
                // Do not update state if newHost.alias is already used for other hosts.
                return false
            }
            return newHost != oldHost
        default:
            return false
        }
    }
    
    private static func latestHostAliasReducer(_ action: Action, state: HostsState) -> String {
        switch action {
        case let action as SelectHost:
            return action.host.alias
        case let action as UpdateHost:
            let newHost = action.newHost
            let oldHost = action.oldHost
            if newHost.alias != oldHost.alias, state.allHosts.keys.contains(newHost.alias) {
                // Do not update state if newHost.alias is already used for other hosts.
                return state.latestHostAlias
            }
            return newHost.alias
        default:
            return state.latestHostAlias
        }
    }
    
    private static func initialHostsState() -> HostsState {
        return HostsState(
            allHosts: MacHostsInfoService().macHostsInfo(),
            editingHostAlias: nil,
            hostAdded: false,
            hostRemoved: false,
            hostSelected: false,
            hostsUpdated: false,
            latestHostAlias: LatestHostAliasService.alias,
            newHost: nil,
            removedHost: nil
        )
    }
}
