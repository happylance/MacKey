//
//  HostDetailsViewModel.swift
//  MacKey
//
//  Created by Liu Liang on 28/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import ReactiveReSwift
import RxSwift
import RxCocoa

class HostDetailsViewModel {
    let aliasAvailable$: Driver<Bool>
    let saveEnabled$: Driver<Bool>
    
    init(input: (
        alias$: Driver<String>,
        host$: Driver<String>,
        username$: Driver<String>,
        password$: Driver<String>,
        requireTouchID$: Driver<Bool>,
        initialHost: HostInfo
        )) {
        
        let initialAlias = input.initialHost.alias
        aliasAvailable$ = input.alias$
            .withLatestFrom(store.observable.asDriver()) {
                $0 == initialAlias || !$1.hostsState.allHosts.keys.contains($0) }
        
        let aliasValid$ = input.alias$
            .withLatestFrom(aliasAvailable$) { alias, aliasAvailable in
                alias.characters.count > 0 && aliasAvailable }
        
        let hostValid$ = input.host$.map { $0.characters.count > 0 }
        let usernameValid$ = input.username$.map { $0.characters.count > 0 }
        let passwordValid$ = input.password$.map { $0.characters.count > 0 }
        
        let aliasChanged$ = input.alias$.map { $0 != input.initialHost.alias }
        let hostChanged$ = input.host$.map { $0 != input.initialHost.host }
        let usernameChanged$ = input.username$.map { $0 != input.initialHost.user }
        let passwordChanged$ = input.password$.map { $0 != input.initialHost.password }
        let requireTouchIDChanged$ = input.requireTouchID$.map { $0 != input.initialHost.requireTouchID }
        
        let isAnyFieldChanged$ = Driver
            .combineLatest(aliasChanged$,
                           hostChanged$,
                           usernameChanged$,
                           passwordChanged$,
                           requireTouchIDChanged$){
                            $0 || $1 || $2 || $3 || $4 }
        
        saveEnabled$ = Driver
            .combineLatest(aliasValid$,
                           hostValid$,
                           usernameValid$,
                           passwordValid$,
                           isAnyFieldChanged$){
                            $0 && $1 && $2 && $3 && $4 }
    }
}

extension Store {
    var hostsState : HostsState {
        return store.observable.value.hostsState
    }
}
