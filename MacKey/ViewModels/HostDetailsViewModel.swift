//
//  HostDetailsViewModel.swift
//  MacKey
//
//  Created by Liu Liang on 28/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import Foundation
import ReactiveReSwift
import RxSwift
import RxCocoa

class HostDetailsViewModel {
    let aliasAvailable: Driver<Bool>
    let saveEnabled: Driver<Bool>
    
    let initialValues: (
        alias: String,
        host: String,
        username: String,
        password: String
    )
    
    init(input: (
        alias: Driver<String>,
        host: Driver<String>,
        username: Driver<String>,
        password: Driver<String>
        )) {
        let initialHost = store.initialHostInfo()
        initialValues = (initialHost.alias, initialHost.host, initialHost.user, initialHost.password)
        
        aliasAvailable = input.alias.map { store.isAliasAvailable($0) }
        
        let aliasValid = input.alias.map { $0.characters.count > 0 && store.isAliasAvailable($0) }
        let hostValid = input.host.map { $0.characters.count > 0 }
        let usernameValid = input.username.map { $0.characters.count > 0 }
        let passwordValid = input.password.map { $0.characters.count > 0 }
        
        let aliasChanged = input.alias.map { $0 != initialHost.alias }
        let hostChanged = input.host.map { $0 != initialHost.host }
        let usernameChanged = input.username.map { $0 != initialHost.user }
        let passwordChanged = input.password.map { $0 != initialHost.password }
        
        let isAnyFieldChanged = Driver.combineLatest(aliasChanged,
                                                     hostChanged,
                                                     usernameChanged,
                                                     passwordChanged
        ){ $0 || $1 || $2 || $3}
        
        saveEnabled = Driver.combineLatest(aliasValid,
                                           hostValid,
                                           usernameValid,
                                           passwordValid,
                                           isAnyFieldChanged
        ){ $0 && $1 && $2 && $3 && $4}
    }
}

extension Store {
    var hostsState : HostsState {
        return store.observable.value.hostsState
    }
    
    fileprivate func initialHostInfo() -> HostInfo {
        guard let alias = hostsState.editingHostAlias else { return HostInfo() }
        guard let hostInfo = hostsState.allHosts[alias] else { return HostInfo() }
        return hostInfo
    }
    
    fileprivate func isAliasAvailable(_ alias: String) -> Bool {
        if alias == hostsState.editingHostAlias { return true }
        return !hostsState.allHosts.keys.contains(alias)
    }
}
