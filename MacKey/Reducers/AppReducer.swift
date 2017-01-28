//
//  AppReducer.swift
//  MacKey
//
//  Created by Liu Liang on 14/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import ReactiveReSwift

let AppReducer = Reducer<State> { action, state in
    let hostsState = HostsReducer.handleAction(action, state:state.hostsState)
    print(hostsState)
    return State(
        hostsState: hostsState
    )
}
