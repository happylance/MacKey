//
//  MacHostsManager.swift
//  MacKey
//
//  Created by Liu Liang on 5/14/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

class MacHostsManager {
    static let sharedInstance = MacHostsManager()
    
    var hosts = (KeychainWrapper.objectForKey(Constants.hostsKey) as? [String: MacHost]) ?? [:]
    var latestHostAlias: String {
        get {
            return Constants.defaults.stringForKey(Constants.latestHostAliasKey) ?? ""
        }
        set {
            Constants.defaults.setObject(newValue, forKey: Constants.latestHostAliasKey)
        }
    }
    
    private init(){}
    
    func saveHosts() {
        KeychainWrapper.setObject(self.hosts, forKey: Constants.hostsKey)
    }
    
    func latestHost() -> MacHost? {
        if latestHostAlias == "" {
            return nil
        }
        return hosts[latestHostAlias]
    }
    
    func unlockLatestHost() {
        let latestMacHost = latestHost()
        if latestMacHost != nil {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                latestMacHost?.executeCmd("unlock")
            })
        }
    }
}