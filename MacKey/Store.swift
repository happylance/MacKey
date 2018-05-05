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

protocol Action {}

class Store<S> {
    typealias Reducer = (S, Action) -> S
    let reducer: Reducer
    
    var observable : Observable<S> {
        return state.asObservable()
    }
    
    var value : S {
        return state.value
    }
    
    private let state: BehaviorRelay<S>
    private let actions = PublishRelay<Action>()
    private let disposeBag = DisposeBag()
    
    init(reducer: @escaping Reducer, initialState: S) {
        self.reducer = reducer
        state = BehaviorRelay(value: initialState)
        actions.scan(initialState, accumulator: reducer)
            .bind(to: state)
            .disposed(by: disposeBag)
    }
    
    func dispatch(_ action: Action) {
        dlog("Received action: \(action)")
        actions.accept(action)
    }
    
    func asDriver() -> Driver<S> {
        return state.asDriver()
    }
}
