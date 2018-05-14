//
//  AppReducer.swift
//  MacKey
//
//  Created by Liu Liang on 14/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

extension State: SimpleReducibleState {
    typealias InputAction = Action
    
    func reduce(_ action: Action) -> State {
        var newState = self
        switch action {
        case let action as Upgrade:
            switch action.productType {
            case .sleepMode:
                newState.supportSleepMode = true
            case .skipTouchID:
                newState.supportSkippingTouchID = true
            case .unknown:
                break
            }
        default:
            break
        }
        
        return State(
            hostsState: HostsReducer.handleAction(action, state:hostsState),
            supportSkippingTouchID: newState.supportSkippingTouchID,
            supportSleepMode: newState.supportSleepMode
        )
    }
}
