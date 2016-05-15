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
                /*let latestMacHost = MacHostsManager.sharedInstance.latestHost()
                if latestMacHost != nil {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        latestMacHost?.executeCmd("unlock")
                    })
                }*/
            case .Error(let error):
                 handler(.Failure(error))
            }
        }
        SimpleTouch.presentTouchID("Authentication required to proceed", fallbackTitle: "", callback: callback)
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
    
    static func showExitAlert(error: TouchIDError, controller: UIViewController) {
        let message = getErrorMessage(error)
        let alertVC = UIAlertController(title: "Sorry that this app will exit", message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: {
            (action)->() in
            exit(0)
        })
        alertVC.addAction(defaultAction)
        controller.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    static func isUserCancel(error: TouchIDError) -> Bool {
        return error == .UserCancel
    }

}
