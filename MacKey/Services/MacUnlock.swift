//
//  MacUnlockService.swift
//  MacKey
//
//  Created by Liu Liang on 29/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum UnlockStatus {
    case connecting
    case connectedAndNeedsUnlock
    case connectedWithInfo(info: String)
    case connectionError(error: String)
    case touchIDError(error: String)
    case unlocking
}

class MacUnlock {
    static func wakeUp(host: HostInfo) -> Observable<(HostInfo, UnlockStatus)> {
        let cmd = host.getDetailCommand("wake")
        return SSHService().executeSshCommand(cmd, host: host)
            .map { $0 == "" ? .connectedAndNeedsUnlock : .connectedWithInfo(info: $0) }
            .catchError { error in
                guard let error = error as? SSHSessionError else {
                    return Observable.just(.connectionError(error: ""))
                }
                switch error {
                case let .failedWithResponse(response):
                    return Observable.just(.connectedWithInfo(info: response))
                default: return Observable.just(.connectionError(error: error.debugDescription))
                }
            }
            .startWith(.connecting)
            .map { (host, $0) }
    }
    
    static func runTouchID() -> Observable<UnlockStatus> {
        return Observable.create { observer in
            TouchIDUtils.runTouchID { (result) in
                switch(result) {
                case .success:
                    observer.onNext(.unlocking)
                case .failure:
                    let status = UnlockStatus.connectionError(error: result.error!.localizedDescription)
                    observer.onNext(status)
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    static func unlock(host: HostInfo) -> Observable<UnlockStatus> {
        let cmd = host.getDetailCommand("unlock")
        return SSHService().executeSshCommand(cmd, host: host)
            .map { .connectedWithInfo(info: $0) }
            .catchError { error in
                guard let error = error as? SSHSessionError else {
                    return Observable.just(.connectionError(error: ""))
                }
                switch error {
                case let .failedWithResponse(response):
                    return Observable.just(.connectedWithInfo(info: response))
                default: return Observable.just(.connectionError(error: error.debugDescription))
                }
            }
    }
}
