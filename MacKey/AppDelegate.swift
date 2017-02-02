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

let middleware = Middleware<State>().sideEffect { _, _, action in
        dlog("Received action: \(action)")
    }

// The global application store, which is responsible for managing the appliction state.
let store = Store(
    reducer: AppReducer,
    observable: Variable(State()),
    middleware: middleware
)

private let disposeBag = DisposeBag()
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var viewController: MasterViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let navigationController = self.window!.rootViewController as? UINavigationController
        viewController = navigationController?.topViewController as? MasterViewController
                
        DispatchQueue.main.async {
            store.dispatch(DidFinishLaunching())
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.viewController?.clearUnlockStatus()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        store.dispatch(WillEnterForeground())
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

