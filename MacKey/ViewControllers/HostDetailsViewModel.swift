//
//  HostDetailsViewModel.swift
//  MacKey
//
//  Created by Liu Liang on 28/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import RxSwift
import RxCocoa

class HostDetailsViewModel {

    // - MARK: outputs
    let aliasAvailable$: Driver<Bool>
    let editHostState$: Single<EditHostState>
    let newHost$: Driver<HostInfo>
    let saveEnabled$: Driver<Bool>
    
    init(alias$: Driver<String>,
         host$: Driver<String>,
         username$: Driver<String>,
         password$: Driver<String>,
         requireTouchID$: Driver<Bool>,
         cancelTapped$: Driver<Void>,
         saveTapped$: Driver<Void>,
         initialHost: HostInfo) {
        let initialAlias = initialHost.alias
        aliasAvailable$ = alias$
            .withLatestFrom(store.asDriver()) {
                $0 == initialAlias || !$1.hostsState.allHosts.keys.contains($0) }
        
        let aliasValid$ = alias$
            .withLatestFrom(aliasAvailable$) { alias, aliasAvailable in
                alias.count > 0 && aliasAvailable }
        
        let hostValid$ = host$.map { $0.count > 0 }
        let usernameValid$ = username$.map { $0.count > 0 }
        let passwordValid$ = password$.map { $0.count > 0 }
        
        let aliasChanged$ = alias$.map { $0 != initialHost.alias }
        let hostChanged$ = host$.map { $0 != initialHost.host }
        let usernameChanged$ = username$.map { $0 != initialHost.user }
        let passwordChanged$ = password$.map { $0 != initialHost.password }
        let requireTouchIDChanged$ = requireTouchID$.map { $0 != initialHost.requireTouchID }
        
        let isAnyFieldChanged$ = Driver
            .combineLatest(aliasChanged$,
                           hostChanged$,
                           usernameChanged$,
                           passwordChanged$,
                           requireTouchIDChanged$){
                            $0 || $1 || $2 || $3 || $4 }
        
        saveEnabled$ = Driver
            .combineLatest(aliasValid$, hostValid$, usernameValid$, passwordValid$, isAnyFieldChanged$){
                            $0 && $1 && $2 && $3 && $4 }
        
        newHost$ = Driver.combineLatest(alias$, host$, username$, password$, requireTouchID$) {
            HostInfo(alias: $0, host: $1, user: $2, password: $3, requireTouchID: $4) }
        
        editHostState$ = Observable
            .of(cancelTapped$.map {_ in .cancelled },
                saveTapped$.withLatestFrom(newHost$).map { .saved($0) })
            .merge()
            .take(1)
            .asSingle()
    }
}

extension Store {
    var hostsState : HostsState {
        return store.value.hostsState
    }
}
