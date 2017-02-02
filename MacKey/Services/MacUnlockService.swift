//
//  MacUnlockService.swift
//  MacKey
//
//  Created by Liu Liang on 29/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import RxSwift
import RxCocoa

enum UnlockStatus {
    case connecting
    case connectedAndNeedsUnlock
    case connectedWithInfo(info: String)
    case error(error: String)
    case unlocking
}

class MacUnlockService {
    static func wakeUp(_ host: HostInfo) -> Observable<UnlockStatus> {
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
    
    static func runTouchID(for host: HostInfo) -> Observable<UnlockStatus> {
        return TouchIDService.runTouchID(for: host).map { (success, error) in
            return success ? .unlocking : UnlockStatus.error(error: TouchIDService.getErrorMessage(error))
        }
    }
    
    static func unlock(_ host: HostInfo) -> Observable<UnlockStatus> {
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
