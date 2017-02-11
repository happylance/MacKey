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
    
    static func newHostAfter(_ previousHosts: Hosts, in hosts: Hosts) -> HostInfo? {
        if hosts.count <= previousHosts.count { return nil }
        return hosts.values.filter { !previousHosts.values.contains($0) }
            .first
    }
    
    static func removedHostFrom(_ previousHosts: Hosts, in hosts: Hosts) -> HostInfo? {
        if hosts.count >= previousHosts.count { return nil }
        return previousHosts.values.filter { !hosts.values.contains($0) }
            .first
    }
    
    var sortedHostAliases: [String] {
        return allHosts.keys.sorted()
    }
}
