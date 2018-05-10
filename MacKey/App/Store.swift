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

class Store<S> {
    let reducer: Reducer<S>
    
    var observable : Observable<S> {
        return state.asObservable()
    }
    
    var value : S {
        return state.value
    }
    
    let actions = PublishRelay<Action>()
    
    private let state: BehaviorRelay<S>
    private let disposeBag = DisposeBag()
    
    init(reducer: @escaping Reducer<S>, initialState: S) {
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
