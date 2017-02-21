//
//  UpgradeService.swift
//  MacKey
//
//  Created by Liu Liang on 19/02/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import RxSwift
import SwiftyStoreKit

class UpgradeService {
    static func getProductInfo(by productID: String) -> Observable<RetrieveResults> {
        return Observable.create { observer in
            SwiftyStoreKit.retrieveProductsInfo([productID], completion: {
                observer.onNext($0)
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
    
    static func restorePurchase() -> Observable<RestoreResults> {
        return Observable.create { observer in
            SwiftyStoreKit.restorePurchases(atomically: true) {
                observer.onNext($0)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    static func purchase(by productID: String) -> Observable<PurchaseResult> {
        return Observable.create { observer in
            SwiftyStoreKit.purchaseProduct(productID, atomically: true) {
                observer.onNext($0)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}


