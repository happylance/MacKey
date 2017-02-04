//
//  AppDelegate.swift
//  MacKey
//
//  Created by Liu Liang on 5/14/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import UIKit
import ReactiveReSwift
import RxSwift

let middleware = Middleware<State>().sideEffect { _, _, action in
        dlog("Received action: \(action)")
    }

// The global application store, which is responsible for managing the appliction state.
let store = Store(
    reducer: AppReducer,
    observable: Variable(State()),
    middleware: middleware
)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        DispatchQueue.main.async {
            store.dispatch(DidFinishLaunching())
        }
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        store.dispatch(DidEnterBackground())
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        store.dispatch(WillEnterForeground())
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

