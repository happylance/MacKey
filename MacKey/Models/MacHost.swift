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

class MacHost: NSObject, NSCoding {
    var alias: String = ""
    var host: String = ""
    var user: String = ""
    var password: String = ""
    
    override init() {
    }
    
    init?(alias: String, host: String, user: String, password: String) {
        if alias.characters.count == 0 {
            return nil
        }
        
        self.alias = alias
        self.host = host
        self.user = user
        self.password = password
    }
    
    init(hostInfo: HostInfo) {
        self.alias = hostInfo.alias
        self.host = hostInfo.host
        self.user = hostInfo.user
        self.password = hostInfo.password
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let alias = aDecoder.decodeObject(forKey: aliasKey) as! String
        let host = aDecoder.decodeObject(forKey: hostKey) as! String
        let user = aDecoder.decodeObject(forKey: userKey) as! String
        let password = aDecoder.decodeObject(forKey: passwordKey) as! String
        
        self.init(alias: alias, host: host, user: user, password: password)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.alias, forKey: aliasKey)
        aCoder.encode(self.host, forKey: hostKey)
        aCoder.encode(self.user, forKey: userKey)
        aCoder.encode(self.password, forKey: passwordKey)
    }
    
    func hostInfo() -> HostInfo {
        return HostInfo(alias: alias, host: host, user: user, password: password)
    }
}
