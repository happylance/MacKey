//
//  MacHostsInfoService.swift
//  MacKey
//
//  Created by Liu Liang on 14/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

fileprivate let hostsKey = "Hosts"

class MacHostsInfoService {
    
    func macHostsInfo() -> Hosts {
        let hostsData = KeychainWrapper.standard.object(forKey:hostsKey)
        if let hostsFromKeyChain = hostsData as? [String: MacHost] {
            return toHostsInfo(legacyMacHosts: hostsFromKeyChain)
        }
        return Hosts()
    }
    
    func saveMacHostsInfo(hosts: Hosts) {
        let legacyMacHosts = toLegacyMacHosts(hostsInfo: hosts)
        let data = NSKeyedArchiver.archivedData(withRootObject:legacyMacHosts)
        KeychainWrapper.standard.set(data, forKey: hostsKey)
    }
    
    private func toHostsInfo(legacyMacHosts: [String: MacHost]) -> [String: HostInfo] {
        var hostsInfo = [String: HostInfo]()
        legacyMacHosts.forEach { (source: (key: String, value: MacHost)) in
            var hostInfo = source.value.hostInfo()
            hostInfo.alias = source.key
            hostsInfo[hostInfo.alias] = hostInfo
        }
        return hostsInfo
    }
    
    private func toLegacyMacHosts(hostsInfo: [String: HostInfo]) -> [String: MacHost] {
        var legacyMacHosts = [String: MacHost]()
        hostsInfo.forEach { (source: (key: String, value: HostInfo)) in
            legacyMacHosts[source.key] = MacHost(hostInfo: source.value)
        }
        return legacyMacHosts
    }
}
