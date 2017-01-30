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

enum WakeUpResponse {
    case connecting
    case connectedAndNeedsUnlock
    case connectedWithInfo(info: String)
    case connectionError(error: String)
}

class MacUnlockService {
    func wakeUp(host: HostInfo) -> Observable<WakeUpResponse> {
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
    }
}
