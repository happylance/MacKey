//
//  TouchIDUtils.swift
//  MacKey
//
//  Created by Liu Liang on 5/15/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import LocalAuthentication
import RxSwift

class TouchIDService {
    
    static func runTouchID(for host: HostInfo) -> Observable<(Bool, Error?)> {
        return Observable.create { observer in
            let context = LAContext()
            context.localizedFallbackTitle = ""
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: String(format:"Authentication required to unlock '%@'".localized(), host.alias))
            { success, error in
                observer.onNext((success, error))
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    static func getErrorMessage(_ error: Error?) -> String {
        guard let error = error as? LAError else {
            return "Touch ID error"
        }
        switch error.code {
        case .appCancel:
            return "App cancelled authentication"
        case .authenticationFailed:
            return "Authentication failed"
        case .invalidContext:
            return "Invalid authentication context"
        case .passcodeNotSet:
            return "User's passcode not set"
        case .systemCancel:
            return "System cancelled authetication"
        case .touchIDLockout:
            return "User is locked out of Touch ID"
        case .touchIDNotAvailable:
            return "Touch ID is not available on this device"
        case .touchIDNotEnrolled:
            return "User has not enrolled for Touch ID"
        case .userCancel:
            return "User cancelled authentication"
        case .userFallback:
            return "User opted for fallback authentication"
        }
    }
}
