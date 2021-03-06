//
//  DataMock.swift
//  MacKeyUnitTests
//
//  Created by Liu Liang on 5/8/18.
//  Copyright © 2018 Liu Liang. All rights reserved.
//

import Foundation
@testable import MacKeyUnit

class DataMock {
    static let twoHosts = HostsState(
        allHosts: [
            "h1": HostInfo(alias: "h1", host: "host1", user: "u1", password: "p1", requireTouchID: true),
            "h2": HostInfo(alias: "h2", host: "host2", user: "u2", password: "p2", requireTouchID: true)
        ],
        latestHostAlias: "h1")
}
