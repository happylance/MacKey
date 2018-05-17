//
//  HostDetailsViewState.swift
//  MacKey
//
//  Created by Liu Liang on 5/13/18.
//  Copyright © 2018 Liu Liang. All rights reserved.
//

import Foundation

enum HostDetailsViewInputAction {
    case changeAlias(String),
    changeHost(String),
    changeUsername(String),
    changePassword(String),
    requireTouchIDTapped,
    cancelTapped,
    saveTapped,
    didUpgrade
}

enum HostDetailsViewOutputAction {
    case askForUpgrade, dismiss(HostInfo?)
}

struct HostDetailsViewState {
    var hostInfo: HostInfo
    var allHostKeys: [String]
    var supportSkippingTouchID: Bool
}

extension HostDetailsViewState {
    func aliasAvailable(initialAlias: String) -> Bool {
        return hostInfo.alias == initialAlias || !allHostKeys.contains(hostInfo.alias)
    }
    
    func hostValid(initialAlias: String) -> Bool {
        return [hostInfo.alias.count > 0,
                aliasAvailable(initialAlias: initialAlias),
                hostInfo.host.count > 0,
                hostInfo.user.count > 0,
                hostInfo.password.count > 0]
            .reduce(true) { $0 && $1 }
    }
    
    func saveEnabled(initialHost: HostInfo) -> Bool {
        return hostValid(initialAlias: initialHost.alias) && hostInfo != initialHost
    }
}

extension HostDetailsViewState: ReducibleState {
    func reduce(_ inputAction: HostDetailsViewInputAction) -> (HostDetailsViewState?, HostDetailsViewOutputAction?) {
        var newState = self
        switch inputAction {
        case .changeAlias(let alias):
            newState.hostInfo.alias = alias
            return (newState, nil)
        case .changeHost(let host):
            newState.hostInfo.host = host
            return (newState, nil)
        case .changeUsername(let user):
            newState.hostInfo.user = user
            return (newState, nil)
        case .changePassword(let password):
            newState.hostInfo.password = password
            return (newState, nil)
        case .requireTouchIDTapped:
            fallthrough
        case .didUpgrade:
            if case .didUpgrade = inputAction {
                newState.supportSkippingTouchID = true
            }
            if (!hostInfo.requireTouchID || newState.supportSkippingTouchID) {
                newState.hostInfo.requireTouchID = !hostInfo.requireTouchID
                return (newState, nil)
            }
            return (newState, .askForUpgrade)
        case .cancelTapped:
            return (nil, .dismiss(nil))
        case .saveTapped:
            return (nil, .dismiss(hostInfo))
        }
    }
}
