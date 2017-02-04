//
//  HostInfo.swift
//  MacKey
//
//  Created by Liu Liang on 15/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

struct HostInfo: CustomStringConvertible {
    var alias: String = ""
    var host: String = ""
    var user: String = ""
    var password: String = ""
    
    var description: String {
        return "(\(alias),\(host),\(user))"
    }
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
