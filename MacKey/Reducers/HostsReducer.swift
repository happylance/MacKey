//
//  HostsReducer.swift
//  MacKey
//
//  Created by Liu Liang on 14/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import ReactiveReSwift

struct HostsReducer {
    static func handleAction(_ action: Action, state: HostsState?) -> HostsState {
        let state = state ?? initialHostsState()
        return HostsState(
            allHosts: allHostsReducer(action, state: state),
            editingHostAlias: editingHostAliasReducer(action, state: state),
            latestConnectionTime: latestConnectionTimeReducer(action, state: state),
            latestHostAlias: latestHostAliasReducer(action, state: state)
        )
    }
    
    static func initialHostsState() -> HostsState {
        return HostsState(
            allHosts: MacHostsInfoService().macHostsInfo(),
            editingHostAlias: nil,
            latestConnectionTime: nil,
            latestHostAlias: LatestHostAliasService.alias
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
    
    private static func latestConnectionTimeReducer(_ action: Action, state: HostsState) -> TimeInterval? {
        switch action {
        case _ as SelectHost:
            return now()
        case _ as DidFinishLaunching:
            return now()
        case _ as WillEnterForeground:
            return now()
        default:
            return state.latestConnectionTime
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
    
    static func now() -> TimeInterval {
        return Date().timeIntervalSince1970
    }
}