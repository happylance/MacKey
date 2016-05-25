//
//  MacHost+SSH.swift
//  MacKey
//
//  Created by Liu Liang on 5/14/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import Foundation
import Result

extension MacHost {
    func executeCmd(cmd: String) -> Result<String, NSError> {
        if cmd == "unlock" {
            let command = getDetailCommand(cmd)
            var result = SshUtils.executeSshCmdWithPassword(command, host: host, username: user, password: password)
            switch result {
            case .Success:
                if result.value! == "" {
                    result = .Success("Mac is unlocked")
                }
            default:
                break
            }
            return result
        }

        return .Failure(NSError(domain:"MacKey", code: 121, userInfo: [NSLocalizedDescriptionKey : "This command is not supported."]))
    }
    
    func getDetailCommand(cmd: String) -> String {
        switch cmd {
        case "unlock":
            return "caffeinate  -u -t 1;" +  // Wake up the screen.
                "d=$(/usr/bin/python -c 'import Quartz; print Quartz.CGSessionCopyCurrentDictionary()');" +
                "echo $d | grep -q 'OnConsoleKey = 0' && { echo 'Needs to unlock manually'; echo $d; return; };" +
                "echo $d | grep -q 'ScreenIsLocked = 1' || { echo 'Mac is already unlocked'; return; }; " +
                "osascript -e 'tell application \"System Events\"' -e 'keystroke \"\(self.password)\"' -e 'delay 0.5' -e 'keystroke return' -e 'end tell'"
        case "sleep":
            return "osascript -e 'tell application \"Finder\" to sleep'"
        default:
            return cmd;
        }
    }
}