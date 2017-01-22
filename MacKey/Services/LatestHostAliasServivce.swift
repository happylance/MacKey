//
//  LatestHostAliasServivce.swift
//  MacKey
//
//  Created by Liu Liang on 15/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import ReSwift

private let latestHostAliasKey = "latestHostAlias"

class LatestHostAliasService : NSObject, StoreSubscriber {
    static private let subscriber = LatestHostAliasService()
    override class func initialize() { DispatchQueue.main.async(execute: { subscribe() }) }
    private class func subscribe() { store.subscribe(subscriber) { $0.hostsState } }
    
    static var alias: String {
        get {
            let latestHostAlias = UserDefaults.standard.string(forKey: latestHostAliasKey) ?? ""
            subscriber.cachedAlias = latestHostAlias
            return latestHostAlias
        }
    }
    private var cachedAlias: String?

    func newState(state: HostsState) {
        if state.latestHostAlias != cachedAlias {
            cachedAlias = state.latestHostAlias
            UserDefaults.standard.set(state.latestHostAlias, forKey: latestHostAliasKey)
            UserDefaults.standard.synchronize()
        }
    }
}
