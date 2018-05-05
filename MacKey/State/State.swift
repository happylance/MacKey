//
//  AppState.swift
//  MacKey
//
//  Created by Liu Liang on 14/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//


struct State {
    var hostsState = HostsReducer.initialHostsState()
    var supportSkippingTouchID = UserDefaultsServivce().supportSkippingTouchID
    var supportSleepMode = UserDefaultsServivce().supportSleepMode
}
