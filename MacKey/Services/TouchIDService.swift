//
//  TouchIDUtils.swift
//  MacKey
//
//  Created by Liu Liang on 5/15/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import SimpleTouch
import RxSwift

class TouchIDService {
    
    static func runTouchID() -> Observable<TouchIDResponse> {
        return Observable.create { observer in
            SimpleTouch.presentTouchID(touchIDRequestMessage(), fallbackTitle: "") { response in
                observer.onNext(response)
            }
            return Disposables.create()
        }
    }
    
    static func touchIDRequestMessage() -> String {
        let latestHostAlias = store.observable.value.latestHostAlias
        if latestHostAlias.characters.count > 0 {
            return "Authentication required to unlock '\(latestHostAlias)'"
        } else {
            return "Authentication required to proceed"
        }
    }
    
    static func getErrorMessage(_ error: TouchIDError) -> String {
        switch error {
        case .appCancel:
            return "App cancelled authentication"
        case .authenticationFailed:
            return "Authentication failed"
        case .invalidContext:
            return "Invalid authentication context"
        case .passcodeNotSet:
            return "Users passcode not set"
        case .systemCancel:
            return "System cancelled authetication"
        case .touchIDLockout:
            return "User is locked out of Touch ID"
        case .touchIDNotAvailable:
            return "Touch ID is not available on this device"
        case .touchIDNotEnrolled:
            return "User has not enrolled for Touch ID"
        case .undeterminedState:
            return "Undetermined error. If you can get this message to display I'd love to know how."
        case .unknownError(let error):
            return "Unknown error. If you can get this message to display I'd love to know how. Error description: \(error.localizedDescription)"
        case .userCancel:
            return "User cancelled authentication"
        case .userFallback:
            return "User opted for fallback authetication"
        }
    }
}
