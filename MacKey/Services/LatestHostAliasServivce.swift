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
class LatestHostAliasService : NSObject {
    static private let subscriber = LatestHostAliasService()
    override class func initialize() { DispatchQueue.main.async(execute: { subscribe() }) }
    private class func subscribe() {
        store.observable.asObservable().map { $0.hostsState.latestHostAlias }
            .distinctUntilChanged().skip(1)
            .subscribe(onNext: {
                UserDefaults.standard.set($0, forKey: latestHostAliasKey)
                UserDefaults.standard.synchronize()
            })
        .disposed(by: disposeBag)
    }
    
    static var alias: String {
        get {
            return UserDefaults.standard.string(forKey: latestHostAliasKey) ?? ""
        }
    }
}
