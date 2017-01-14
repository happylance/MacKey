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
    
    var hostsData = KeychainWrapper.standard.object(forKey:Constants.hostsKey)
    var hosts = [String: MacHost]()
    var latestHostAlias: String {
        get {
            return Constants.defaults.string(forKey: Constants.latestHostAliasKey) ?? ""
        }
        set {
            Constants.defaults.set(newValue, forKey: Constants.latestHostAliasKey)
        }
    }
    
    fileprivate init(){
        if let hostsFromKeyChain = hostsData as? [String: MacHost] {
            hosts = hostsFromKeyChain
        }
    }
    
    func saveHosts() {
        let data = NSKeyedArchiver.archivedData(withRootObject:self.hosts)
        KeychainWrapper.standard.set(data, forKey: Constants.hostsKey)
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
            DispatchQueue.global().async(execute: {
                latestMacHost?.executeCmd("unlock")
            })
        }
    }
}
