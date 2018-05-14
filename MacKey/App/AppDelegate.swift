//
//  AppDelegate.swift
//  MacKey
//
//  Created by Liu Liang on 5/14/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import UIKit
import RxSwift

private let initialHostsState = HostsState(
    allHosts: MacHostsInfoService().macHostsInfo(),
    latestHostAlias: UserDefaultsServivce().latestHostAlias
)

// The global application store, which is responsible for managing the appliction state.
let store = Store(
    initialState: State(hostsState: initialHostsState, supportSkippingTouchID: UserDefaultsServivce().supportSkippingTouchID, supportSleepMode: UserDefaultsServivce().supportSleepMode)
)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        AppCoordinator().start()
        return true
    }
}

@discardableResult func dlog<T>(_ arg: T) -> T {
    return debugLog(arg)
}

@discardableResult func dlog(_ arg: String) -> String {
    return debugLog(arg)
}

private func debugLog<T>(_ arg: T) -> T {
    #if DEBUG
        print(arg)
    #endif
    return arg
}

