//
//  AppCoordinator.swift
//  MacKey
//
//  Created by Liu Liang on 5/5/18.
//  Copyright © 2018 Liu Liang. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import RxSwift

class AppCoordinator {
    private let appHelper = AppHelper(state: store.observable)
    private let disposeBag = DisposeBag()
    private let userDefaultsService = UserDefaultsServivce()
    
    init() {
    }
    
    func start() {
        MacHostsInfoService.register()
        
        userDefaultsService.saveWhenChanges(appHelper)
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            let productsHelper = PurchasesHelper(purchases)
            productsHelper.pendingTransactions
                .forEach { SwiftyStoreKit.finishTransaction($0) }
            
            productsHelper.upgrades.forEach { store.dispatch($0) }
        }
    }
}
