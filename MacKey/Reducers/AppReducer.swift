//
//  AppReducer.swift
//  MacKey
//
//  Created by Liu Liang on 14/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import ReactiveReSwift

let AppReducer = Reducer<State> { action, state in
    return State(
        hostsState: dlog(HostsReducer.handleAction(action, state:state.hostsState)),
        isAppInBackground: isAppInBackgroundReducer(action, state.isAppInBackground)
    )
}

private func isAppInBackgroundReducer(_ action:Action, _ state: Bool) -> Bool {
    switch action {
    case is DidEnterBackground: return true
    case is DidFinishLaunching: return false
    case is WillEnterForeground: return false
    default: return state
    }
}
