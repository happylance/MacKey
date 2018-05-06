//
//  PurchasesHelper.swift
//  MacKey
//
//  Created by Liu Liang on 5/5/18.
//  Copyright © 2018 Liu Liang. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import StoreKit

class PurchasesHelper {
    let pendingTransactions: [PaymentTransaction]
    let upgrades: [Upgrade]
    
    init(_ purchases: [Purchase]) {
        let purchasedOrRestoredPurchases = purchases.filter {
            $0.transaction.transactionState.isPurchasedOrRestored }
        pendingTransactions = purchasedOrRestoredPurchases
            .filter { $0.needsFinishTransaction }
            .map { $0.transaction }
        upgrades = purchasedOrRestoredPurchases
            .map { Upgrade(productID: $0.productId) }
    }
}


private extension SKPaymentTransactionState {
    var isPurchasedOrRestored: Bool {
        return self == .purchased || self == .restored
    }
}
