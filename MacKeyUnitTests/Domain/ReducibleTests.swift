//
//  ReducibleTests.swift
//  MacKeyUnitTests
//
//  Created by Liu Liang on 5/12/18.
//  Copyright © 2018 Liu Liang. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import MacKeyUnit

struct ReducibleTestsState: ReducibleState {
    typealias InputAction = ReducibleTestsInputAction
    
    typealias OutputAction = ReducibleTestsOutputAction
    
    let sum: Int
    
    func reduce(_ inputAction:ReducibleTestsInputAction) -> (ReducibleTestsState, ReducibleTestsOutputAction?) {
        switch inputAction {
        case .add(let num):
            return (ReducibleTestsState(sum: sum + num),  nil)
        case .inputAction:
            return (self,  .outputAction)
        }
    }
}

enum ReducibleTestsInputAction {
    case add(Int), inputAction
    
}

enum ReducibleTestsOutputAction {
    case outputAction
}

class ReducibleTests: XCTestCase {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var initialState = ReducibleTestsState(sum: 0)
    
    var inputActions = PublishRelay<ReducibleTestsInputAction>()
    
    
    func testGetStateAndActions() {
        [true, false]
            .forEach {
                let scheduler = TestScheduler(initialClock: 0)
                _ = scheduler.createHotObservable([next(300, .inputAction), next(400, .add(2)), next(500, .add(1))])
                    .bind(to: inputActions)
                let (state, outputActions) = initialState.getStateAndActions(inputActions: inputActions, disposeBag: disposeBag)
                
                if $0 {
                    let result = scheduler.start { state.asObservable() }
                    XCTAssertEqual(result.events.compactMap { $0.value.element?.sum }, [0, 0, 2, 3])
                } else {
                    let result = scheduler.start { outputActions.asObservable() }
                    XCTAssertEqual(result.events.count, 1)
                }
        }
    }
    
    func testGetStateAndEmptyActions() {
        [true, false]
            .forEach {
                let scheduler = TestScheduler(initialClock: 0)
                _ = scheduler.createHotObservable([next(300, .add(1))])
                    .bind(to: inputActions)
                let (state, outputActions) = initialState.getStateAndActions(inputActions: inputActions, disposeBag: disposeBag)
                
                if $0 {
                    let result = scheduler.start { state.asObservable() }
                    XCTAssertEqual(result.events.compactMap { $0.value.element?.sum }, [0, 1])
                } else {
                    let result = scheduler.start { outputActions.asObservable() }
                    XCTAssertEqual(result.events.count, 0)
                }
        }
    }
}
