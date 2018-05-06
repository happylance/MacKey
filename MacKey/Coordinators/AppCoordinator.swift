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
    }
}
