//
//  AppReducer.swift
//  MacKey
//
//  Created by Liu Liang on 14/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import ReactiveReSwift

let AppReducer : Reducer<State> = { action, state in
    var (supportSkippingTouchID, supportSleepMode) = { () -> (Bool, Bool) in 
        switch action {
        case let action as Upgrade:
            guard let productType = UpgradeViewController.productType(by: action.productID) else {
                return (state.supportSkippingTouchID, state.supportSleepMode)
            }
            switch productType {
            case .sleepMode:
                return (state.supportSkippingTouchID, true)
            case .skipTouchID:
                return (true, state.supportSleepMode)
            }
        default:
            return (state.supportSkippingTouchID, state.supportSleepMode)
        }
    }()
    
    return State(
        hostsState: dlog(HostsReducer.handleAction(action, state:state.hostsState)),
        supportSkippingTouchID: supportSkippingTouchID,
        supportSleepMode: supportSleepMode
    )
}
