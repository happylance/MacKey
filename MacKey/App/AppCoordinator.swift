//
//  AppCoordinator.swift
//  MacKey
//
//  Created by Liu Liang on 5/5/18.
//  Copyright © 2018 Liu Liang. All rights reserved.
//

import Foundation
import SwiftyStoreKit

class AppCoordinator {
    init() {
    }
    
    func start() {
        MacHostsInfoService.register()
        UserDefaultsServivce.register()
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            let productsHelper = PurchasesHelper(purchases)
            productsHelper.pendingTransactions
                .forEach { SwiftyStoreKit.finishTransaction($0) }
            
            productsHelper.upgrades.forEach { store.dispatch($0) }
        }
    }
}
