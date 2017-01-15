//
//  HostInfo.swift
//  MacKey
//
//  Created by Liu Liang on 15/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

struct HostInfo {
    var alias: String = ""
    var host: String = ""
    var user: String = ""
    var password: String = ""
}

extension HostInfo: Equatable {
    static func ==(lhs: HostInfo, rhs: HostInfo) -> Bool {
        let areEqual = (lhs.alias == rhs.alias &&
            lhs.host == rhs.host &&
            lhs.user == rhs.user &&
            lhs.password == rhs.password)
        
        return areEqual
    }
}
