//
//  Store.swift
//  MacKey
//
//  Created by Liu Liang on 5/5/18.
//  Copyright © 2018 Liu Liang. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class Store {
    
    var observable : Observable<State> {
        return state.asObservable()
    }
    
    var value : State {
        return state.value
    }
    
    let actions = PublishRelay<Action>()
    
    private let state: BehaviorRelay<State>
    private let disposeBag = DisposeBag()
    
    init(initialState: State) {
        state = initialState.getState(actions: actions, disposeBag: disposeBag)
    }
    
    func dispatch(_ action: Action) {
        dlog("Received action: \(action)")
        actions.accept(action)
    }
    
    func asDriver() -> Driver<State> {
        return state.asDriver()
    }
}
