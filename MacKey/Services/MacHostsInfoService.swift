//
//  MacHostsInfoService.swift
//  MacKey
//
//  Created by Liu Liang on 14/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import SwiftKeychainWrapper
import ReactiveReSwift
import RxSwift

fileprivate let hostsKey = "Hosts"
private let disposeBag = DisposeBag()
class MacHostsInfoService : NSObject {    
    static func register() {
        subscribe()
    }
    
    func macHostsInfo() -> Hosts {
        let hostsData = KeychainWrapper.standard.object(forKey:hostsKey)
        if let hostsFromKeyChain = hostsData as? [String: MacHost] {
            let hosts = toHostsInfo(legacyMacHosts: hostsFromKeyChain)
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
        store.observable.asObservable().map { $0.hostsState.allHosts }
            .distinctUntilChanged { $0 == $1 }
            .skip(1)
            .subscribe(onNext: { (allHosts: Hosts) in
                var legacyMacHosts = [String: MacHost]()
                allHosts.forEach { (source: (key: String, value: HostInfo)) in
                    legacyMacHosts[source.key] = MacHost(hostInfo: source.value)
                }
                let data = NSKeyedArchiver.archivedData(withRootObject:legacyMacHosts)
                KeychainWrapper.standard.set(data, forKey: hostsKey)
        }).disposed(by: disposeBag)
    }
}
