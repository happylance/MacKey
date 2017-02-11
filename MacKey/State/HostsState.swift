//
//  HostsState.swift
//  MacKey
//
//  Created by Liu Liang on 14/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import Foundation

struct HostsState {
    var allHosts: Hosts
    var latestHostAlias: String
}

typealias Hosts = [String: HostInfo]

extension HostsState {
    var sortedHostAliases: [String] {
        return allHosts.keys.sorted()
    }
}
