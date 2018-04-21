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
import SwiftyStoreKit

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
        MacHostsInfoService.register()
        UserDefaultsServivce.register()
        
        SwiftyStoreKit.completeTransactions(atomically: true) { products in
            
            for product in products {
                
                if product.transaction.transactionState == .purchased || product.transaction.transactionState == .restored {
                    
                    if product.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(product.transaction)
                    }
                    dlog("purchased: \(product)")
                    store.dispatch(Upgrade(productID: product.productId))
                }
            }
        }
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

