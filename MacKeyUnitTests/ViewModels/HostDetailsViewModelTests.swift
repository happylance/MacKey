//
//  HostDetailsViewModelTests.swift
//  MacKeyUnitTests
//
//  Created by Liu Liang on 5/11/18.
//  Copyright © 2018 Liu Liang. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxCocoa
@testable import MacKeyUnit

class HostDetailsViewModelTests: XCTestCase {
    let initialHost = HostInfo(alias: "a", host: "h", user: "u", password: "p", requireTouchID: true)
    lazy var initialState = HostDetailsViewState(hostInfo: initialHost,
        allHostKeys: ["a", "b"],
        supportSkippingTouchID: false)
    
    let scheduler = TestScheduler(initialClock: 0)
    
    lazy var viewModel = HostDetailsViewModel(initialState: initialState)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAliasAvailable() {
        _ = scheduler.createHotObservable(
            [(300, "a"), (400, "b"), (500, "c")]
                .map { next($0.0, .changeAlias($0.1))})
            .bind(to: viewModel.inputActions)
        
        let result = scheduler.start { self.viewModel.aliasAvailable$ }
        
        XCTAssertEqual(result.events.map { $0.value.element! }, [true, false, true])
    }
    
    func testSaveEnabledForAliasChange() {
        _ = scheduler.createHotObservable(
            [(300, "a"), (400, "b"), (500, "c"), (600, "")]
                .map { next($0.0, .changeAlias($0.1))})
            .bind(to: viewModel.inputActions)
        
        let result = scheduler.start { self.viewModel.saveEnabled$ }
        
        XCTAssertEqual(result.events.map { $0.value.element! }, [false, true, false])
    }
    
    func testSaveEnabledForHostChange() {
        _ = scheduler.createHotObservable(
            [(300, "h"), (500, "c"), (600, "")]
                .map { next($0.0, .changeHost($0.1))})
            .bind(to: viewModel.inputActions)
        
        let result = scheduler.start { self.viewModel.saveEnabled$ }
        
        XCTAssertEqual(result.events.map { $0.value.element! }, [false, true, false])
    }
    
    func testSaveEnabledForUserChange() {
        _ = scheduler.createHotObservable(
            [(300, "u"), (500, "c"), (600, "")]
                .map { next($0.0, .changeUsername($0.1))})
            .bind(to: viewModel.inputActions)
        
        let result = scheduler.start { self.viewModel.saveEnabled$ }
        
        XCTAssertEqual(result.events.map { $0.value.element! }, [false, true, false])
    }
    
    func testSaveEnabledForPasswordChange() {
        _ = scheduler.createHotObservable(
            [(300, "p"), (500, "c"), (600, "")]
                .map { next($0.0, .changePassword($0.1))})
            .bind(to: viewModel.inputActions)
        
        let result = scheduler.start { self.viewModel.saveEnabled$ }
        
        XCTAssertEqual(result.events.map { $0.value.element! }, [false, true, false])
    }
    
    func testSaveEnabledForRequireTouchIDChange() {
        _ = scheduler.createHotObservable(
            [300, 350, 500, 600]
                .map { next($0, .requireTouchIDTapped) })
            .bind(to: viewModel.inputActions)
        
        _ = scheduler.createHotObservable(
            [next(400, .didUpgrade)])
            .bind(to: viewModel.inputActions)
        
        let result = scheduler.start { self.viewModel.saveEnabled$ }
        
        // requireTouchID: 200 true, 300 true, 400 false, 500 true, 600 false
        XCTAssertEqual(result.events, [next(200, false), next(400, true), next(500, false), next(600, true)])
    }
    
    func testRequireTouchID() {
        _ = scheduler.createHotObservable(
            [300, 350, 500, 600]
                .map { next($0, .requireTouchIDTapped) })
            .bind(to: viewModel.inputActions)
        
        _ = scheduler.createHotObservable(
            [next(400, .didUpgrade)])
            .bind(to: viewModel.inputActions)
        
        let result = scheduler.start { self.viewModel.requireTouchID$ }
        
        XCTAssertEqual(result.events, [next(200, true), next(400, false), next(500, true), next(600, false)])
    }
    
    func testAskForUpgrade() {
        _ = scheduler.createHotObservable(
            [300, 350, 500, 600]
                .map { next($0, .requireTouchIDTapped) })
            .bind(to: viewModel.inputActions)
        
        _ = scheduler.createHotObservable(
            [next(400, .didUpgrade)])
            .bind(to: viewModel.inputActions)
        
        let result = scheduler.start { self.viewModel.askForUpgrade$ }
        
        XCTAssertEqual(result.events.map { $0.time }, [300, 350])
    }
    
    func testDismiss() {
        [(true, Optional(HostInfo(alias: "a1", host: "h1", user: "u1", password: "p1", requireTouchID: false))),
         (false, nil)]
            .forEach {
                let scheduler = TestScheduler(initialClock: 0)
                let viewModel = HostDetailsViewModel(initialState: initialState)
                
                _ = scheduler.createHotObservable(
                    [next(300, .changeAlias("a1")),
                     next(400, .changeHost("h1")),
                     next(500, .changeUsername("u1")),
                     next(600, .changePassword("p1")),
                     next(700, .requireTouchIDTapped),
                     next(800, .didUpgrade),
                     next(900, $0 ? .saveTapped : .cancelTapped)])
                    .bind(to: viewModel.inputActions)
                
                let result = scheduler.start { viewModel.dismiss$ }
                
                XCTAssertEqual(result.events, [next(900, $1), completed(900)])
        }
    }
    
}
