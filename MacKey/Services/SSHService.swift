//
//  NMSSHSession+Rx.swift
//  MacKey
//
//  Created by Liu Liang on 29/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import Foundation
import NMSSH
import RxSwift

enum SSHSessionError: Swift.Error {
    case authenticationFailed
    case connectionFailed
    case failedToCreateSession
    case failedWithError(error: NSError)
    case failedWithResponse(response: String)
    case noResponse
    case unknown
}

extension SSHSessionError: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .authenticationFailed:
            return "Authentication failed"
        case .connectionFailed:
            return "Connection failed"
        case .failedToCreateSession:
            return "Failed to create NMSSHSession"
        case let .failedWithError(error):
            return "SSH request failed with error: `\(error.description)`"
        case let .failedWithResponse(response):
            return "SSH request failed with response: `\(response)`"
        case .noResponse:
            return "Response is nil"
        case .unknown:
            return "Unknown error has occurred"
        }
    }
}

class SSHService {
    func executeSshCommand(_ command: String, host: HostInfo) -> Observable<String> {
        return Observable.create { observer in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let session = NMSSHSession(host:host.host, andUsername:host.user) else {
                    observer.onError(SSHSessionError.failedToCreateSession)
                    return
                }
                
                session.connect(); defer { session.disconnect() }
                if session.isConnected {
                    session.authenticateByKeyboardInteractive({ (request: String?) -> String? in
                        return host.password
                    })
                    if !session.isAuthorized {
                        observer.onError(SSHSessionError.authenticationFailed)
                        return
                    }
                } else {
                    observer.onError(SSHSessionError.connectionFailed)
                    return
                }
                
                var error : NSError? = nil
                let logLevel = NMSSHLogger.shared().logLevel
                NMSSHLogger.shared().logLevel = .error
                guard let response = session.channel.execute(command, error:&error, timeout:10) else {
                    observer.onError(SSHSessionError.noResponse)
                    return
                }
                NMSSHLogger.shared().logLevel = logLevel
                if let error = error {
                    if response.characters.count > 0 {
                        observer.onError(SSHSessionError.failedWithResponse(response: response))
                        return
                    }
                    observer.onError(SSHSessionError.failedWithError(error: error))
                    return
                }
                observer.onNext(response)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
