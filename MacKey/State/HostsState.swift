//
//  HostsState.swift
//  MacKey
//
//  Created by Liu Liang on 14/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

struct HostsState {
    var allHosts = Hosts()
    var newHost: HostInfo? = nil
    var removedHost: HostInfo? = nil
    var hostsUpdated = false
    var latestHostAlias = ""
    var hostSelected = false
}

typealias Hosts = [String: HostInfo]
