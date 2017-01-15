//
//  AppReducer.swift
//  MacKey
//
//  Created by Liu Liang on 14/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import ReSwift

struct AppReducer: Reducer {
    func handleAction(action: Action, state: State?) -> State {
        return State(
            hostsState: HostsReducer.handleAction(action, state:state?.hostsState)
        )
    }

}
