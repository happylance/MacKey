//
//  SshUtils.swift
//  Commands
//
//  Created by Liu Liang on 5/2/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import Foundation
import NMSSH
import Result

class SshUtils {
    static func executeSshCmdWithPassword(_ command: String, host: String, username: String, password: String) -> Result<String, NSError> {
        guard let session = NMSSHSession(host:host, andUsername:username) else {
            return .failure(NSError(domain:"Commands", code: 101, userInfo: [NSLocalizedDescriptionKey : "Failed to create NMSSHSession"]))
        }
        session.connect()
        if session.isConnected {
            session.authenticateByKeyboardInteractive({ (request: String?) -> String? in
                return password
            })
            if session.isAuthorized {
                print("Authentication succeeded");
            } else {
                return .failure(NSError(domain:"Commands", code: 101, userInfo: [NSLocalizedDescriptionKey : "Authentication failed"]))
            }
        } else {
            return .failure(NSError(domain:"Commands", code: 102, userInfo: [NSLocalizedDescriptionKey : "Connection failed"]))
        }
        
        var error : NSError? = nil
        let logLevel = NMSSHLogger.shared().logLevel
        NMSSHLogger.shared().logLevel = .error
        guard let response = session.channel.execute(command, error:&error, timeout:10) else {
            return .failure(NSError(domain:"Commands", code: 102, userInfo: [NSLocalizedDescriptionKey : "Response is nil"]))
        }
        NMSSHLogger.shared().logLevel = logLevel
        if let error = error {
            if response.characters.count > 0 {
                return .failure(NSError(domain:"Commands", code: 1, userInfo: [NSLocalizedDescriptionKey : response]))
            }
            print(error)
            return .failure(error)
        }
        
        print(response)
        session.disconnect()
        return .success(response)
    }
}
