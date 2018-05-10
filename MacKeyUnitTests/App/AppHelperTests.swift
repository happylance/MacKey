//
//  AppHelperTests.swift
//  MacKeyUnitTests
//
//  Created by Liu Liang on 5/7/18.
//  Copyright © 2018 Liu Liang. All rights reserved.
//

import XCTest
import RxTest
import RxCocoa
import RxSwift
@testable import MacKeyUnit

private let initialState = State(hostsState: HostsState(allHosts: [:], latestHostAlias: ""), supportSkippingTouchID: false, supportSleepMode: false)

class AppHelperTests: XCTestCase {
    let scheduler = TestScheduler(initialClock: 0)
    let disposeBag = DisposeBag()
    let state = BehaviorRelay(value: initialState)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        var newState = initialState
        newState.hostsState.latestHostAlias = "1"
        newState.supportSkippingTouchID = true
        newState.supportSleepMode = true
        
        scheduler.createHotObservable([next(300, newState)])
            .bind(to:state).disposed(by: disposeBag)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLatestHostAliasKey() {
        let appHelper = AppHelper(state: state.asObservable())
        let result = scheduler.start { appHelper.latestHostAliasSkipFirst }
        XCTAssertEqual(result.events.count, 1)
        XCTAssertEqual(result.events[0].value.element, "1")
    }
    
    func testSupportSkippingTouchID() {
        let appHelper = AppHelper(state: state.asObservable())
        let result = scheduler.start { appHelper.supportSkippingTouchIDSkipFirst }
        XCTAssertEqual(result.events.count, 1)
        XCTAssertEqual(result.events[0].value.element, true)
    }
    
    func testSupportSleepMode() {
        let appHelper = AppHelper(state: state.asObservable())
        let result = scheduler.start { appHelper.supportSleepModeSkipFirst }
        XCTAssertEqual(result.events.count, 1)
        XCTAssertEqual(result.events[0].value.element, true)
    }
}
