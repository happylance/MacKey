//
//  UpgradeViewController.swift
//  MacKey
//
//  Created by Liu Liang on 19/02/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyStoreKit


private let sleepModeProductID = "com.nlprliu.MacKey.pro"
private let skipTouchIDProductID = "com.nlprliu.MacKey.skipTouchID"

private let buttonCornerRadius: CGFloat = 5

enum ProductType {
    case sleepMode, skipTouchID
}

private func productID(by type: ProductType) -> String {
    switch type {
    case .sleepMode:
        return sleepModeProductID
    case .skipTouchID:
        return skipTouchIDProductID
    }
}

enum PurchaseState {
    case purchased, cancelled
}

class UpgradeViewController: UIViewController{
    @IBOutlet weak var activityIndicatorOutlet: UIActivityIndicatorView!
    @IBOutlet weak var cancelOutlet: UIBarButtonItem!
    @IBOutlet weak var productDetailsOutlet: UILabel!
    @IBOutlet weak var purchaseOutlet: UIButton!
    @IBOutlet weak var restorePurchaseOutlet: UIButton!
    
    private let disposeBag = DisposeBag()
    private let productType$ = Variable<ProductType>(.sleepMode)
    private let purchaseState$ = PublishSubject<PurchaseState>()
    
    func getPurchaseState$() -> Observable<PurchaseState> {
        return purchaseState$.asObservable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        purchaseOutlet.layer.cornerRadius = buttonCornerRadius
        restorePurchaseOutlet.layer.cornerRadius = buttonCornerRadius
        
        cancelOutlet.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.purchaseState$.onNext(.cancelled)
                self.purchaseState$.onCompleted()
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        productType$.asObservable()
            .map { productID(by: $0) }
            .do(onNext: { [unowned self] _ in self.activityIndicatorOutlet.isHidden = false })
            .flatMapLatest { UpgradeService.getProductInfo(by: $0) }
            .subscribe(onNext: { [unowned self] result in
                self.activityIndicatorOutlet.isHidden = true
                if let product = result.retrievedProducts.first {
                    let priceString = product.localizedPrice!
                    dlog("Product: \(product.localizedDescription), price: \(priceString)")
                    self.productDetailsOutlet.isHidden = false
                    self.productDetailsOutlet.text = product.localizedDescription
                    self.purchaseOutlet.isHidden = false
                    self.purchaseOutlet.setTitle(priceString, for: .normal)
                }
                else if let invalidProductId = result.invalidProductIDs.first {
                    return self.alertWithTitle(
                        "Could not retrieve product info",
                        message: String(format:"Invalid product identifier: %@".localized(), invalidProductId))
                }
                else {
                    dlog("Error: \(result.error)")
                    if let error = result.error as? NSError {
                        self.alertWithTitle("Error", message: error.localizedDescription)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        purchaseOutlet.rx.tap
            .withLatestFrom(productType$.asObservable()) { productID(by: $1) }
            .do(onNext: { [unowned self] _ in self.activityIndicatorOutlet.isHidden = false })
            .flatMapLatest { UpgradeService.purchase(by: $0) }
            .subscribe(onNext: { [unowned self] result in
                self.activityIndicatorOutlet.isHidden = true
                switch result {
                case .success(let product):
                    dlog("Purchase Success: \(product.productId)")
                    store.dispatch(Upgrade(productID: product.productId))
                    self.purchaseState$.onNext(.purchased)
                    self.purchaseState$.onCompleted()
                    self.dismiss(animated: true, completion: nil)
                case .error(let error):
                    dlog("Purchase Failed: \(error)")
                    self.alertWithTitle("Purchase Failed", message: {
                        switch(error.code) {
                        case .storeProductNotAvailable:
                            return String(format:"Store product not available")
                        case .paymentNotAllowed:
                            return "Payment not allowed"
                        default:
                            return error._nsError.localizedDescription
                        }
                    }())
                }
            })
            .disposed(by: disposeBag)
        
        restorePurchaseOutlet.rx.tap
            .do(onNext: { [unowned self] _ in self.activityIndicatorOutlet.isHidden = false })
            .flatMapLatest {_ in UpgradeService.restorePurchase() }
            .withLatestFrom(productType$.asObservable()) { ($0, productID(by: $1)) }
            .subscribe(onNext: { [unowned self] (results, productId) in
                self.activityIndicatorOutlet.isHidden = true
                if results.restoreFailedPurchases.count > 0 {
                    dlog("Restore Failed: \(results.restoreFailedPurchases)")
                    let message = { () -> String in 
                        if let error = results.restoreFailedPurchases.first?.0._nsError {
                            return error.localizedDescription
                        }
                        return ""
                    }()
                    self.alertWithTitle("Restore Unsuccessful", message: message)
                }
                else if results.restoredPurchases.count > 0 {
                    dlog("Restore Success: \(results.restoredPurchases)")
                    if (results.restoredPurchases.contains { $0.productId == productId }) {
                        store.dispatch(Upgrade(productID: productId))
                        self.purchaseState$.onNext(.purchased)
                        self.purchaseState$.onCompleted()
                        self.dismiss(animated: true, completion: nil)
                        return
                    } else {
                        self.alertWithTitle("Restore Unsuccessful", message: "You purchased another product but not this one")
                        return
                    }
                }
                else {
                    dlog("Nothing to Restore")
                    self.alertWithTitle("Restore Unsuccessful", message: "Nothing to restore")
                }
            })
            .disposed(by: disposeBag)
    }
    
    func setProductType(_ type: ProductType) {
        productType$.value = type
    }
    
    static func productType(by id: String) -> ProductType? {
        if id == sleepModeProductID {
            return .sleepMode
        } else if id == skipTouchIDProductID {
            return .skipTouchID
        }
        return nil
    }
    
    private func alertWithTitle(_ title: String, message: String) {
        let alertView = UIAlertController(title: title.localized(), message: message.localized(), preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK".localized(), style: .cancel) { _ in
        })
        self.present(alertView, animated: true, completion: nil)
    }
}
