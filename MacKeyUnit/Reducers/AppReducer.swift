//
//  AppReducer.swift
//  MacKey
//
//  Created by Liu Liang on 14/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

let appReducer : Reducer<State> = { state, action in
    var (supportSkippingTouchID, supportSleepMode) = { () -> (Bool, Bool) in 
        switch action {
        case let action as Upgrade:
            switch action.productType {
            case .sleepMode:
                return (state.supportSkippingTouchID, true)
            case .skipTouchID:
                return (true, state.supportSleepMode)
            case .unknown:
                return (state.supportSkippingTouchID, state.supportSleepMode)
            }
        default:
            return (state.supportSkippingTouchID, state.supportSleepMode)
        }
    }()
    
    return State(
        hostsState: HostsReducer.handleAction(action, state:state.hostsState),
        supportSkippingTouchID: supportSkippingTouchID,
        supportSleepMode: supportSleepMode
    )
}
