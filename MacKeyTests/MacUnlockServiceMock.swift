//
//  MacUnlockServiceMock.swift
//  MacKeyTests
//
//  Created by Liu Liang on 4/22/18.
//  Copyright © 2018 Liu Liang. All rights reserved.
//

import Foundation
import RxSwift
import RxTest
@testable import MacKey

class MacUnlockServiceMock: MacUnlockUseCase {
    var wakeUpReturnValue: Observable<UnlockStatus> = .empty()
    var runTouchIDReturnValue: Observable<UnlockStatus> = .empty()
    var unlockReturnValue: Observable<UnlockStatus> = .empty()
    var checkStatusReturnValue: Observable<UnlockStatus> = .empty()
    var sleepReturnValue: Observable<UnlockStatus> = .empty()
    
    func wakeUp(_ host: HostInfo) -> Observable<UnlockStatus> {
        return wakeUpReturnValue
    }
    
    func runTouchID(for host: HostInfo) -> Observable<UnlockStatus> {
        return runTouchIDReturnValue
    }
    
    func unlock(_ host: HostInfo) -> Observable<UnlockStatus> {
        return unlockReturnValue
    }
    
    func checkStatus(_ host: HostInfo) -> Observable<UnlockStatus> {
        return checkStatusReturnValue
    }
    
    func sleep(_ host: HostInfo) -> Observable<UnlockStatus> {
        return sleepReturnValue
    }
}
