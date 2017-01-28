//
//  updateHost.swift
//  MacKey
//
//  Created by Liu Liang on 14/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import ReactiveReSwift

struct UpdateHost: Action {
    let oldHost: HostInfo
    let newHost: HostInfo
}
