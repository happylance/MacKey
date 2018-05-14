//
//  SimpleReducible.swift
//  MacKey
//
//  Created by Liu Liang on 5/12/18.
//  Copyright © 2018 Liu Liang. All rights reserved.
//
import RxSwift
import RxCocoa

protocol SimpleReducibleState {
    associatedtype InputAction
    func reduce(_ action:InputAction) -> Self
}

extension SimpleReducibleState {
    func getState(actions: PublishRelay<InputAction>, disposeBag: DisposeBag) -> BehaviorRelay<Self> {
        let state = BehaviorRelay<Self>(value: self)
        actions
            .scan(self) { $0.reduce($1) }
            .bind(to: state)
            .disposed(by: disposeBag)
        return state
    }
}

