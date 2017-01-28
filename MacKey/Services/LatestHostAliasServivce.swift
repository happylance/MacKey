//
//  LatestHostAliasServivce.swift
//  MacKey
//
//  Created by Liu Liang on 15/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import ReactiveReSwift
import RxSwift

private let latestHostAliasKey = "latestHostAlias"
private let disposeBag = DisposeBag()
private var cachedAlias: String?
class LatestHostAliasService : NSObject {
    static private let subscriber = LatestHostAliasService()
    override class func initialize() { DispatchQueue.main.async(execute: { subscribe() }) }
    private class func subscribe() {
        store.observable.asObservable().map { $0.hostsState }
            .subscribe(onNext: {
                if $0.latestHostAlias != cachedAlias {
                    cachedAlias = $0.latestHostAlias
                    UserDefaults.standard.set($0.latestHostAlias, forKey: latestHostAliasKey)
                    UserDefaults.standard.synchronize()
                }
            })
        .addDisposableTo(disposeBag)
    }
    
    static var alias: String {
        get {
            let latestHostAlias = UserDefaults.standard.string(forKey: latestHostAliasKey) ?? ""
            cachedAlias = latestHostAlias
            return latestHostAlias
        }
    }
}
