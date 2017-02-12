//
//  MacHost.swift
//  MacKey
//
//  Created by Liu Liang on 5/14/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import Foundation

fileprivate let aliasKey = "alias"
fileprivate let hostKey = "host"
fileprivate let userKey = "user"
fileprivate let passwordKey = "password"
fileprivate let skipTouchIDKey = "skipTouchID"

class MacHost: NSObject, NSCoding {
    var alias = ""
    var host = ""
    var user = ""
    var password = ""
    var requireTouchID = true
    
    override init() {
    }
    
    init?(alias: String, host: String, user: String, password: String, requireTouchID: Bool) {
        if alias.characters.count == 0 {
            return nil
        }
        
        self.alias = alias
        self.host = host
        self.user = user
        self.password = password
        self.requireTouchID = requireTouchID
    }
    
    init(hostInfo: HostInfo) {
        self.alias = hostInfo.alias
        self.host = hostInfo.host
        self.user = hostInfo.user
        self.password = hostInfo.password
        self.requireTouchID = hostInfo.requireTouchID
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let alias = aDecoder.decodeObject(forKey: aliasKey) as? String,
            let host = aDecoder.decodeObject(forKey: hostKey) as? String,
            let user = aDecoder.decodeObject(forKey: userKey) as? String,
            let password = aDecoder.decodeObject(forKey: passwordKey) as? String
            else { return nil }
        
        let requireTouchID = !aDecoder.decodeBool(forKey: skipTouchIDKey)
        self.init(alias: alias, host: host, user: user, password: password, requireTouchID: requireTouchID)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.alias, forKey: aliasKey)
        aCoder.encode(self.host, forKey: hostKey)
        aCoder.encode(self.user, forKey: userKey)
        aCoder.encode(self.password, forKey: passwordKey)
        aCoder.encode(!self.requireTouchID, forKey: skipTouchIDKey)
    }
    
    func hostInfo() -> HostInfo {
        return HostInfo(alias: alias, host: host, user: user, password: password, requireTouchID: requireTouchID)
    }
}
