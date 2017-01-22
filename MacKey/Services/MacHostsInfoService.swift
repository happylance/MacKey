//
//  MacHostsInfoService.swift
//  MacKey
//
//  Created by Liu Liang on 14/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import ReSwift

fileprivate let hostsKey = "Hosts"

class MacHostsInfoService : NSObject {
    static fileprivate let subscriber = MacHostsInfoService()
    override class func initialize() { DispatchQueue.main.async(execute: { subscribe() }) }
    fileprivate var cachedHosts: Hosts = Hosts()
    
    func macHostsInfo() -> Hosts {
        let hostsData = KeychainWrapper.standard.object(forKey:hostsKey)
        if let hostsFromKeyChain = hostsData as? [String: MacHost] {
            let hosts = toHostsInfo(legacyMacHosts: hostsFromKeyChain)
            MacHostsInfoService.subscriber.cachedHosts = hosts
            return hosts
        }
        return Hosts()
    }
    
    fileprivate func saveMacHostsInfo(hosts: Hosts) {
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

extension MacHostsInfoService: StoreSubscriber {
    fileprivate class func subscribe() { store.subscribe(subscriber) { $0.hostsState } }
    func newState(state: HostsState) {
        if state.allHosts != cachedHosts {
            cachedHosts = state.allHosts
            saveMacHostsInfo(hosts: state.allHosts)
        }
    }
}
