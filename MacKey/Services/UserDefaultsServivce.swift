//
//  UserDefaultsServivce.swift
//  MacKey
//
//  Created by Liu Liang on 15/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import ReactiveReSwift
import RxSwift

private let supportSleepModeKey = "supportSleepMode"
private let supportSkippingTouchIDKey = "supportSkippingTouchID"
private let latestHostAliasKey = "latestHostAlias"
private let disposeBag = DisposeBag()
class UserDefaultsServivce : NSObject {
    static func register() {
        subscribe()
    }
    
    private class func subscribe() {
        store.observable.asObservable().map { $0.hostsState.latestHostAlias }
            .distinctUntilChanged().skip(1)
            .subscribe(onNext: {
                UserDefaults.standard.set($0, forKey: latestHostAliasKey)
                UserDefaults.standard.synchronize()
            })
        .disposed(by: disposeBag)
        
        store.observable.asObservable().map { $0.supportSkippingTouchID }
            .distinctUntilChanged().skip(1)
            .subscribe(onNext: {
                UserDefaults.standard.set($0, forKey: supportSkippingTouchIDKey)
                UserDefaults.standard.synchronize()
            })
            .disposed(by: disposeBag)
        
        store.observable.asObservable().map { $0.supportSleepMode }
            .distinctUntilChanged().skip(1)
            .subscribe(onNext: {
                UserDefaults.standard.set($0, forKey: supportSleepModeKey)
                UserDefaults.standard.synchronize()
            })
            .disposed(by: disposeBag)
    }
    
    var supportSkippingTouchID: Bool {
        get {
            return UserDefaults.standard.bool(forKey: supportSkippingTouchIDKey)
        }
    }
    
    var supportSleepMode: Bool {
        get {
            return UserDefaults.standard.bool(forKey: supportSleepModeKey)
        }
    }
    
    var latestHostAlias: String {
        get {
            return UserDefaults.standard.string(forKey: latestHostAliasKey) ?? ""
        }
    }
}
