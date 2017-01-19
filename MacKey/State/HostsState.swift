//
//  HostsState.swift
//  MacKey
//
//  Created by Liu Liang on 14/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

struct HostsState {
    var allHosts: Hosts
    var hostAdded: Bool
    var hostRemoved: Bool
    var hostSelected: Bool
    var hostsUpdated: Bool
    var latestHostAlias = ""
    var newHost: HostInfo? = nil
    var removedHost: HostInfo? = nil
}

typealias Hosts = [String: HostInfo]
