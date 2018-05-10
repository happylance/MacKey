//
//  MasterViewModelTests.swift
//  MacKeyTests
//
//  Created by Liu Liang on 4/22/18.
//  Copyright © 2018 Liu Liang. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxCocoa
@testable import MacKeyUnit

class MasterViewModelTests: XCTestCase {
    var testScheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var macUnlockService: MacUnlockServiceMock!
    var viewModel: MasterViewModel!
    var state1 = DataMock.twoHosts
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        testScheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        macUnlockService = MacUnlockServiceMock()
        viewModel = MasterViewModel(macUnlockService: macUnlockService)
    }
    
    func testHasSelectedCell() {
        setHostsState()
        
        let result = testScheduler.start { self.viewModel.hasSelectedCell$ }
        XCTAssertEqual(result.events.count, 1)
        XCTAssertEqual(result.events[0].value.element, true)
    }
    
    func testHasNoSelectedCell() {
        state1.latestHostAlias = ""
        setHostsState()
        
        let result = testScheduler.start { self.viewModel.hasSelectedCell$ }
        XCTAssertEqual(result.events.count, 1)
        XCTAssertEqual(result.events[0].value.element, false)
    }
    
    func testHasSelectedIndex() {
        state1.latestHostAlias = ""
        setHostsState()
        setUnlockRequest()
        
        let result = testScheduler.start { self.viewModel.selectedIndex$ }
        XCTAssertEqual(result.events.count, 1)
        XCTAssertEqual(result.events[0].value.element!.1.latestHostAlias, state1.latestHostAlias)
    }
    
    func testHasNoSelectedIndex() {
        state1.latestHostAlias = ""
        setHostsState()
        
        let result = testScheduler.start { self.viewModel.selectedIndex$ }
        XCTAssertEqual(result.events.count, 0)
    }
    
    func testSelectedCellStatusUpdate() {
        SharingScheduler.mock(scheduler: testScheduler) {
            statusFlows.forEach {
                macUnlockService.wakeUpReturnValue = .just($0.0)
                macUnlockService.runTouchIDReturnValue = .just($0.1)
                macUnlockService.unlockReturnValue = .just($0.2)
                viewModel = MasterViewModel(macUnlockService: macUnlockService)
                setHostsState()
                setUnlockRequest()
                
                let result = testScheduler.start { self.viewModel.selectedCellStatusUpdate$ }
                XCTAssertEqual(result.events.count, 1)
                XCTAssertEqual(result.events[0].value.element!, $0.3)
            }
        }
        
        SharingScheduler.mock(scheduler: testScheduler) {
            statusFlows.forEach {
                macUnlockService.wakeUpReturnValue = .just($0.0)
                macUnlockService.runTouchIDReturnValue = .just($0.1)
                macUnlockService.unlockReturnValue = .just($0.2)
                viewModel = MasterViewModel(macUnlockService: macUnlockService)
                setHostsState()
                enterForeground()
                
                let result = testScheduler.start { self.viewModel.selectedCellStatusUpdate$ }
                XCTAssertEqual(result.events.count, 1)
                XCTAssertEqual(result.events[0].value.element!, $0.3)
            }
        }
        
        SharingScheduler.mock(scheduler: testScheduler) {
            statusFlows.forEach {
                macUnlockService.wakeUpReturnValue = .just($0.0)
                macUnlockService.runTouchIDReturnValue = .just($0.1)
                macUnlockService.unlockReturnValue = .just($0.2)
                viewModel = MasterViewModel(macUnlockService: macUnlockService)
                setHostsState()
                enterBackground()
                
                let result = testScheduler.start { self.viewModel.selectedCellStatusUpdate$ }
                XCTAssertEqual(result.events.count, 1)
                XCTAssertEqual(result.events[0].value.element!, "")
            }
        }
    }
    
    var statusFlows : [(UnlockStatus, UnlockStatus, UnlockStatus, String)] {
        return [(.connectedAndNeedsUnlock, .unlocking,
                 .connectedWithInfo(info: "done"), "done"),
                (.connectedAndNeedsUnlock, .unlocking,
                 .connectedWithInfo(info: "failed"), "failed"),
                (.connectedAndNeedsUnlock, .unlocking,
                 .error(error: ""), ""),
                (.connectedAndNeedsUnlock, .unlocking,
                 .error(error: "ssh error"), "ssh error"),
                (.connectedAndNeedsUnlock, .connectedAndNeedsUnlock,
                 .connectedAndNeedsUnlock, "Require touch ID"),
                (.connectedAndNeedsUnlock, .unlocking,
                 .unlocking, "Unlocking..."),
                (.connectedAndNeedsUnlock, .error(error: "App cancelled authentication"),
                 .unlocking, "App cancelled authentication"),
                (.connectedWithInfo(info: "done\n"), .error(error: ""),
                 .unlocking, "done")]
    }
    
    func setHostsState() {
        testScheduler.createHotObservable([next(300, state1)])
            .bind(to: viewModel.hostsState)
            .disposed(by: disposeBag)
    }
    
    func setUnlockRequest() {
        testScheduler.createHotObservable([next(400, IndexPath(item: 0, section: 0))])
            .bind(to: viewModel.unlockRequest)
            .disposed(by: disposeBag)
    }
    
    func enterForeground() {
        testScheduler.createHotObservable([next(400, ())])
            .bind(to: viewModel.enterForeground)
            .disposed(by: disposeBag)
    }
    
    func enterBackground() {
        testScheduler.createHotObservable([next(400, ())])
            .bind(to: viewModel.enterBackground)
            .disposed(by: disposeBag)
    }
        
}
