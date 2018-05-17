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
    
    func reduce(_ inputAction:InputAction) -> (Self?, OutputAction?)
}

extension ReducibleState {
    func getStateAndActions(inputActions: PublishRelay<InputAction>, disposeBag: DisposeBag) -> (BehaviorRelay<Self>, PublishRelay<OutputAction>) {
        let state = BehaviorRelay(value: self)
        let outputActions = PublishRelay<OutputAction>()
        
        inputActions.scan((self, nil, nil)) { (arg0, action: InputAction) -> (Self, Self?, OutputAction?) in
            let (previousState, _, _) = arg0
            let (newState, outputAction) = previousState.reduce(action)
                return (newState ?? previousState, newState, outputAction)
            }
            .subscribe(onNext: {
                if let newState = $0.1 {
                    state.accept(newState)
                }
                if let action = $0.2 {
                    outputActions.accept(action)
                }
            })
            .disposed(by: disposeBag)
        
        return (state, outputActions)
    }
}
