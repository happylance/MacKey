//
//  AppState.swift
//  MacKey
//
//  Created by Liu Liang on 14/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import ReactiveReSwift

struct State : StateType {
    var hostsState: HostsState = HostsReducer.initialHostsState()
    var isAppInBackground: Bool = false
}

extension State {
    var allHosts: Hosts {
        return hostsState.allHosts
    }
    

    var latestHostAlias: String {
        return hostsState.latestHostAlias
    }
}