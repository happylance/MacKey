//
//  MacHostsInfoService.swift
//  MacKey
//
//  Created by Liu Liang on 14/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import ReactiveReSwift
import RxSwift

fileprivate let hostsKey = "Hosts"
private let disposeBag = DisposeBag()
private var cachedHosts: Hosts = Hosts()
class MacHostsInfoService : NSObject {
    static fileprivate let subscriber = MacHostsInfoService()
    override class func initialize() { DispatchQueue.main.async(execute: { subscribe() }) }
    
    func macHostsInfo() -> Hosts {
        let hostsData = KeychainWrapper.standard.object(forKey:hostsKey)
        if let hostsFromKeyChain = hostsData as? [String: MacHost] {
            let hosts = toHostsInfo(legacyMacHosts: hostsFromKeyChain)
            cachedHosts = hosts
            return hosts
        }
        return Hosts()
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

extension MacHostsInfoService {
    fileprivate class func subscribe() {
        store.observable.asObservable().map { $0.hostsState }
            .subscribe(onNext: {
                if $0.allHosts != cachedHosts {
                    cachedHosts = $0.allHosts
                    
                    var legacyMacHosts = [String: MacHost]()
                    $0.allHosts.forEach { (source: (key: String, value: HostInfo)) in
                        legacyMacHosts[source.key] = MacHost(hostInfo: source.value)
                    }
                    let data = NSKeyedArchiver.archivedData(withRootObject:legacyMacHosts)
                    KeychainWrapper.standard.set(data, forKey: hostsKey)
                }
        }).addDisposableTo(disposeBag)
    }
}
