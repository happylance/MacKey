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
    let initialState: HostDetailsViewState
    
    let inputActions = PublishRelay<HostDetailsViewInputAction>()
    
    private let state$: BehaviorRelay<HostDetailsViewState>
    
    private let outputActions$: PublishRelay<HostDetailsViewOutputAction>
    
    private let disposeBag = DisposeBag()

    init(initialState: HostDetailsViewState) {
        self.initialState = HostDetailsViewState(
            hostInfo: initialState.hostInfo,
            allHostKeys: initialState.allHostKeys,
            supportSkippingTouchID: initialState.supportSkippingTouchID)
        
        (state$, outputActions$) = self.initialState
            .getStateAndActions(inputActions: inputActions, disposeBag: disposeBag)
    }
}

extension HostDetailsViewModel {
    var aliasAvailable$: Observable<Bool> {
        let initialAlias = initialState.hostInfo.alias
        return state$.map { $0.aliasAvailable(initialAlias: initialAlias) }
            .distinctUntilChanged()
    }
    
    var saveEnabled$: Observable<Bool> {
        let initialHost = initialState.hostInfo
        return state$
            .map { $0.saveEnabled(initialHost: initialHost) }
            .distinctUntilChanged()
    }
    
    var requireTouchID$: Observable<Bool> {
        return state$.map { $0.hostInfo.requireTouchID }.distinctUntilChanged()
    }
    
    var askForUpgrade$: Observable<()> {
        return outputActions$
            .flatMap { action -> Observable<()> in
                if case .askForUpgrade = action {
                    return .just(())
                }
                return .empty()
        }
    }
    
    var dismiss$: Observable<HostInfo?> {
        return outputActions$
            .flatMap { action -> Observable<HostInfo?> in
                switch action {
                case .dismiss(let host):
                    return .just(host)
                default:
                    return .empty()
                }
            }
            .take(1)
    }
}
