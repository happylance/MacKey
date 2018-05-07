//
//  UserDefaultsServivce.swift
//  MacKey
//
//  Created by Liu Liang on 15/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

private let supportSleepModeKey = "supportSleepMode"
private let supportSkippingTouchIDKey = "supportSkippingTouchID"
private let latestHostAliasKey = "latestHostAlias"
private let disposeBag = DisposeBag()

protocol UserDefaultsPersistable {
    var latestHostAliasKeySkipFirst: Observable<String> { get }
    var supportSkippingTouchIDSkipFirst: Observable<Bool> { get }
    var supportSleepModeKeySkipFirst: Observable<Bool> { get }
}

class UserDefaultsServivce : NSObject {
    private let userDefaults: UserDefaults
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    func saveWhenChanges(_ persistable: UserDefaultsPersistable) {
        [persistable.latestHostAliasKeySkipFirst.subscribe(onNext: { [weak self] in
            self?.latestHostAlias = $0
        }),
         persistable.supportSkippingTouchIDSkipFirst.subscribe(onNext: { [weak self] in
            self?.supportSkippingTouchID = $0
         }),
         persistable.supportSleepModeKeySkipFirst.subscribe(onNext: { [weak self] in
            self?.supportSleepMode = $0
         })].forEach { $0.disposed(by: disposeBag) }
    }
    
    private(set) var supportSkippingTouchID: Bool {
        get {
            return userDefaults.bool(forKey: supportSkippingTouchIDKey)
        }
        set {
            userDefaults.set(newValue, forKey: supportSkippingTouchIDKey)
            userDefaults.synchronize()
        }
    }
    
    private(set) var supportSleepMode: Bool {
        get {
            return userDefaults.bool(forKey: supportSleepModeKey)
        }
        set {
            userDefaults.set(newValue, forKey: supportSleepModeKey)
            userDefaults.synchronize()
        }
    }
    
    private(set) var latestHostAlias: String {
        get {
            return userDefaults.string(forKey: latestHostAliasKey) ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: latestHostAliasKey)
            userDefaults.synchronize()
        }
    }
}
