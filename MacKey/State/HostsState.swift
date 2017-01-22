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
    var hostAdded: Bool
    var hostRemoved: Bool
    var hostSelected: Bool
    var hostsUpdated: Bool
    var latestHostAlias: String
    var newHost: HostInfo?
    var removedHost: HostInfo?
}

typealias Hosts = [String: HostInfo]
