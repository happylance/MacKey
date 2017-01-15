//
//  AppState.swift
//  MacKey
//
//  Created by Liu Liang on 14/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import ReSwift

struct State : StateType {
    var hostsState = HostsState()
}

extension State {
    var allHosts: Hosts {
        return hostsState.allHosts
    }
    
    var sortedHostAliases: [String] {
        return allHosts.keys.sorted()
    }
    
    var latestHostAlias: String {
        return hostsState.latestHostAlias
    }
    
    var latestHost: HostInfo? {
        return (latestHostAlias != "") ? allHosts[latestHostAlias] : nil
    }
}
