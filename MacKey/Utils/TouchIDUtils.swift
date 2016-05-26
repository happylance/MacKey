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
    static func checkTouchIDSupport(handler:(Result<Bool, TouchIDError>)->()) {
        switch SimpleTouch.hardwareSupportsTouchID {
        case .Success:
            print("Hardware supports Touch ID")
        case .Error(let error):
            handler(.Failure(error))
            return
        }
        
        switch SimpleTouch.isTouchIDEnabled {
        case .Success:
            print("Can evaluate Touch ID")
        case .Error(let error):
            handler(.Failure(error))
            return
        }
        
        runTouchID { (result: Result<Bool, TouchIDError>) in
            handler(result)
        }
    }
    
    static func runTouchID(handler:(Result<Bool, TouchIDError>)->()) {
        let callback: TouchIDPresenterCallback = { response in
            switch response {
            case .Success:
                print("Touch ID evaluated successfully")
                handler(.Success(true))
            case .Error(let error):
                 handler(.Failure(error))
            }
        }
        
        SimpleTouch.presentTouchID(touchIDRequestMessage(), fallbackTitle: "", callback: callback)
    }
    
    static func touchIDRequestMessage() -> String {
        let latestHostAlias = MacHostsManager.sharedInstance.latestHostAlias
        if latestHostAlias.characters.count > 0 {
            return "Authentication required to unlock '\(latestHostAlias)'"
        } else {
            return "Authentication required to proceed"
        }
    }
    
    static func getErrorMessage(error: TouchIDError) -> String {
        switch error {
        case .AppCancel:
            return "App cancelled authentication"
        case .AuthenticationFailed:
            return "Authentication failed"
        case .InvalidContext:
            return "Invalid authentication context"
        case .PasscodeNotSet:
            return "Users passcode not set"
        case .SystemCancel:
            return "System cancelled authetication"
        case .TouchIDLockout:
            return "User is locked out of Touch ID"
        case .TouchIDNotAvailable:
            return "Touch ID is not available on this device"
        case .TouchIDNotEnrolled:
            return "User has not enrolled for Touch ID"
        case .UndeterminedState:
            return "Undetermined error. If you can get this message to display I'd love to know how."
        case .UnknownError(let error):
            return "Unknown error. If you can get this message to display I'd love to know how. Error description: \(error.localizedDescription)"
        case .UserCancel:
            return "User cancelled authentication"
        case .UserFallback:
            return "User opted for fallback authetication"
        }
    }
}
