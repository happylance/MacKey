//
//  MacUnlockService.swift
//  MacKey
//
//  Created by Liu Liang on 29/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import RxSwift
import RxCocoa
import SimpleTouch

enum UnlockStatus {
    case connecting
    case connectedAndNeedsUnlock
    case connectedWithInfo(info: String)
    case error(error: String)
    case unlocking
}

class MacUnlockService {
    static func wakeUp(host: HostInfo) -> Observable<UnlockStatus> {
        let cmd = host.getDetailCommand("wake")
        return SSHService().executeSshCommand(cmd, host: host)
            .map { $0 == "" ? .connectedAndNeedsUnlock : .connectedWithInfo(info: $0) }
            .catchError { error in
                guard let error = error as? SSHSessionError else {
                    return Observable.just(.error(error: ""))
                }
                switch error {
                case let .failedWithResponse(response):
                    return Observable.just(.connectedWithInfo(info: response))
                default: return Observable.just(.error(error: error.debugDescription))
                }
            }
            .startWith(.connecting)
    }
    
    static func runTouchID() -> Observable<UnlockStatus> {
        return TouchIDService.runTouchID().map { (result: TouchIDResponse) in
            switch(result) {
            case .success:
                return .unlocking
            case .error(let error):
                return UnlockStatus.error(error: TouchIDService.getErrorMessage(error))
            }
        }
    }
    
    static func unlock(host: HostInfo) -> Observable<UnlockStatus> {
        let cmd = host.getDetailCommand("unlock")
        return SSHService().executeSshCommand(cmd, host: host)
            .map { .connectedWithInfo(info: $0) }
            .catchError { error in
                guard let error = error as? SSHSessionError else {
                    return Observable.just(.error(error: ""))
                }
                switch error {
                case let .failedWithResponse(response):
                    return Observable.just(.connectedWithInfo(info: response))
                default: return Observable.just(.error(error: error.debugDescription))
                }
            }
    }
}
