//
//  HostsReducer.swift
//  MacKey
//
//  Created by Liu Liang on 14/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import ReSwift

struct HostsReducer {
    static func handleAction(_ action: Action, state: HostsState?) -> HostsState {
        var state = state ?? initialHostsState()
        
        state.newHost = nil
        state.removedHost = nil
        state.hostsUpdated = hostsUpdatedReducer(action: action, state: state)
        state.latestHostAlias = latestHostAliasReducer(action: action, state: state.latestHostAlias)
        state.hostSelected = action is SelectHost

        switch action {
        case let action as AddHost:
            let newHost = action.host
            state.allHosts[newHost.alias] = newHost
            state.newHost = newHost
        case let action as RemoveHost:
            let oldHost = action.host
            state.allHosts.removeValue(forKey: oldHost.alias)
            state.removedHost = oldHost
        case let action as UpdateHost where state.hostsUpdated:
            let updatedHost = action.newHost
            let oldHost = action.oldHost
            if updatedHost.alias != oldHost.alias {
                state.allHosts.removeValue(forKey: oldHost.alias)
            }
            state.allHosts[updatedHost.alias] = updatedHost
        default:
            break
        }
        
        return state
    }
    
    private static func hostsUpdatedReducer(action: Action, state: HostsState) -> Bool {
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
    
    private static func latestHostAliasReducer(action: Action, state: String?) -> String {
        switch action {
        case let action as SelectHost:
            return action.host.alias
        default:
            return state ?? ""
        }
    }
    
    private static func initialHostsState() -> HostsState {
        return HostsState(
            allHosts: MacHostsInfoService().macHostsInfo(),
            newHost: nil,
            removedHost: nil,
            hostsUpdated: false,
            latestHostAlias: LatestHostAliasServivce.alias,
            hostSelected: false
        )
    }
}
