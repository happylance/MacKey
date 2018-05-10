//
//  AppReducerTests.swift
//  MacKeyUnitTests
//
//  Created by Liu Liang on 5/9/18.
//  Copyright © 2018 Liu Liang. All rights reserved.
//

import XCTest
@testable import MacKeyUnit

class AppReducerTests: XCTestCase {
    
    func testUpgrade() {
        let array: [(ProductType, Bool, Bool, Bool, Bool)] =
            [(.skipTouchID, true, true, true, true),
             (.skipTouchID, true, false, true, false),
             (.skipTouchID, false, true, true, true),
             (.skipTouchID, false, false, true, false),
             (.sleepMode, true, true, true, true),
             (.sleepMode, true, false, true, true),
             (.sleepMode, false, true, false, true),
             (.sleepMode, false, false, false, true),
             (.unknown, true, true, true, true),
             (.unknown, true, false, true, false),
             (.unknown, false, true, false, true),
             (.unknown, false, false, false, false)]
        array.forEach {
            let state = State(hostsState:DataMock.twoHosts,
                              supportSkippingTouchID: $1,
                              supportSleepMode: $2)
            let action = Upgrade(productType: $0)
            let newState = appReducer(state, action)
            XCTAssertEqual(newState.supportSkippingTouchID, $3)
            XCTAssertEqual(newState.supportSleepMode, $4)
        }
        
    }
}
