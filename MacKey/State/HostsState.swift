//
//  HostsState.swift
//  MacKey
//
//  Created by Liu Liang on 14/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

struct HostsState {
    var allHosts: Hosts
    var editingHostAlias: String?
    var hostSelected: Bool
    var hostsUpdated: Bool
    var latestHostAlias: String
}

typealias Hosts = [String: HostInfo]

extension HostsState {
    func newHostAfter(_ previousHosts: Hosts) -> HostInfo? {
        if allHosts.count <= previousHosts.count { return nil }
        return allHosts.values.filter { !previousHosts.values.contains($0) }
                .first
    }
    
    func removedHostFrom(_ previousHosts: Hosts) -> HostInfo? {
        if allHosts.count >= previousHosts.count { return nil }
        return previousHosts.values.filter { !self.allHosts.values.contains($0) }
            .first
    }
}
