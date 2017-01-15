//
//  TouchIDUtils.swift
//  MacKey
//
//  Created by Liu Liang on 5/15/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import Foundation
import SimpleTouch
import Result

class TouchIDUtils {
    static func checkTouchIDSupport(_ handler:@escaping (Result<Bool, TouchIDError>)->()) {
        switch SimpleTouch.hardwareSupportsTouchID {
        case .success:
            print("Hardware supports Touch ID")
        case .error(let error):
            handler(.failure(error))
            return
        }
        
        switch SimpleTouch.isTouchIDEnabled {
        case .success:
            print("Can evaluate Touch ID")
        case .error(let error):
            handler(.failure(error))
            return
        }
        
        runTouchID { (result: Result<Bool, TouchIDError>) in
            handler(result)
        }
    }
    
    static func runTouchID(_ handler:@escaping (Result<Bool, TouchIDError>)->()) {
        let callback: TouchIDPresenterCallback = { response in
            switch response {
            case .success:
                print("Touch ID evaluated successfully")
                handler(.success(true))
            case .error(let error):
                 handler(.failure(error))
            }
        }
        
        SimpleTouch.presentTouchID(touchIDRequestMessage(), fallbackTitle: "", callback: callback)
    }
    
    static func touchIDRequestMessage() -> String {
        let latestHostAlias = store.state.latestHostAlias
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
