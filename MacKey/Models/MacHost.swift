//
//  MacHost.swift
//  MacKey
//
//  Created by Liu Liang on 5/14/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import Foundation

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
    
    required convenience init?(coder aDecoder: NSCoder) {
        let alias = aDecoder.decodeObject(forKey: Constants.alias) as! String
        let host = aDecoder.decodeObject(forKey: Constants.host) as! String
        let user = aDecoder.decodeObject(forKey: Constants.user) as! String
        let password = aDecoder.decodeObject(forKey: Constants.password) as! String
        
        self.init(alias: alias, host: host, user: user, password: password)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.alias, forKey: Constants.alias)
        aCoder.encode(self.host, forKey: Constants.host)
        aCoder.encode(self.user, forKey: Constants.user)
        aCoder.encode(self.password, forKey: Constants.password)
    }
    
    
}
