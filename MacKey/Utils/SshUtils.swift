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
    static func executeSshCmdWithPassword(command: String, host: String, username: String, password: String) -> Result<String, NSError> {
        let session = NMSSHSession(host:host, andUsername:username)
        session.connect()
        if session.connected {
            session.authenticateByKeyboardInteractiveUsingBlock({ (request: String!) -> String! in
                return password
            })
            if (session.authorized) {
                print("Authentication succeeded");
            } else {
                return .Failure(NSError(domain:"Commands", code: 101, userInfo: [NSLocalizedDescriptionKey : "Authentication failed"]))
            }
        } else {
            return .Failure(NSError(domain:"Commands", code: 102, userInfo: [NSLocalizedDescriptionKey : "Connection failed"]))
        }
        
        var error : NSError? = nil
        let logLevel = NMSSHLogger.sharedLogger().logLevel
        NMSSHLogger.sharedLogger().logLevel = .Error
        let response = session.channel.execute(command, error:&error, timeout:10)
        NMSSHLogger.sharedLogger().logLevel = logLevel
        if let error = error {
            print(error)
            return .Failure(error)
        }
        
        print(response)
        session.disconnect()
        return .Success(response)
    }
}
