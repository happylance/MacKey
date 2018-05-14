//
//  SimpleReducibleTests.swift
//  MacKeyUnitTests
//
//  Created by Liu Liang on 5/12/18.
//  Copyright © 2018 Liu Liang. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxCocoa
@testable import MacKeyUnit

struct SimpleReducibleTestsState: SimpleReducibleState {
    typealias InputAction = ReducibleTestsInputAction
    
    let sum: Int
    
    func reduce(_ inputAction:ReducibleTestsInputAction) -> SimpleReducibleTestsState{
        switch inputAction {
        case .add(let num):
            return SimpleReducibleTestsState(sum: sum + num)
        case .inputAction:
            return self
        }
    }
}

class SimpleReducibleTests: XCTestCase {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var initialState = SimpleReducibleTestsState(sum: 0)
    
    var inputActions = PublishRelay<ReducibleTestsInputAction>()
    
    var scheduler = TestScheduler(initialClock: 0)
    
    func testGetState() {
        _ = scheduler.createHotObservable([next(300, .add(1)), next(400, .add(2))])
            .bind(to: inputActions)
        
        let state = initialState.getState(actions: inputActions, disposeBag: disposeBag)
        
        let result = scheduler.start { state.asObservable() }
        XCTAssertEqual(result.events.compactMap { $0.value.element?.sum }, [0, 1, 3])
    }
}
