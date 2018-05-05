//
//  HostsReducer.swift
//  MacKey
//
//  Created by Liu Liang on 14/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import Foundation

struct HostsReducer {
    static func handleAction(_ action: Action, state: HostsState) -> HostsState {
        return HostsState(
            allHosts: allHostsReducer(action, state: state),
            latestHostAlias: latestHostAliasReducer(action, state: state)
        )
    }
    
    static func initialHostsState() -> HostsState {
        return HostsState(
            allHosts: MacHostsInfoService().macHostsInfo(),
            latestHostAlias: UserDefaultsServivce().latestHostAlias
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
        case let action as UpdateHost:
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
    
    private static func latestHostAliasReducer(_ action: Action, state: HostsState) -> String {
        switch action {
        case let action as SelectHost:
            return action.host.alias
        case let action as RemoveHost:
            return state.latestHostAlias == action.host.alias ? "" : state.latestHostAlias
        case let action as UpdateHost:
            let newHost = action.newHost
            let oldHost = action.oldHost
            if state.latestHostAlias == oldHost.alias {
                return newHost.alias
            }
            return state.latestHostAlias
        default:
            return state.latestHostAlias
        }
    }
    
    static func now() -> TimeInterval {
        return Date().timeIntervalSince1970
    }
}
