//
//  MockSSHService.swift
//  MacKey
//
//  Created by Liu Liang on 05/03/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import RxSwift
import RxCocoa

class MockSSHService: SSHService {
    override func executeSshCommand(_ command: String, host: HostInfo) -> Observable<String> {
        return Observable.create { observer in
            if let response = ProcessInfo.processInfo.environment["wake"] {
                observer.onNext(response)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
