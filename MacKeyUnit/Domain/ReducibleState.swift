//
//  Reducible.swift
//  MacKey
//
//  Created by Liu Liang on 5/12/18.
//  Copyright © 2018 Liu Liang. All rights reserved.
//

import RxSwift
import RxCocoa

protocol ReducibleState {
    associatedtype InputAction
    associatedtype OutputAction
    
    func reduce(_ inputAction:InputAction) -> (Self, OutputAction?)
}

extension ReducibleState {
    func getStateAndActions(inputActions: PublishRelay<InputAction>, disposeBag: DisposeBag) -> (BehaviorRelay<Self>, PublishRelay<OutputAction>) {
        let state = BehaviorRelay(value: self)
        let outputActions = PublishRelay<OutputAction>()
        
        inputActions.scan((self, nil)) { $0.0.reduce($1) }
            .subscribe(onNext: {
                state.accept($0.0)
                if let action = $0.1 {
                    outputActions.accept(action)
                }
            })
            .disposed(by: disposeBag)
        
        return (state, outputActions)
    }
}
