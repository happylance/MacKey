//
//  MacHost+SSH.swift
//  MacKey
//
//  Created by Liu Liang on 5/14/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import Foundation
import Result

let wakeCommand = "echo 'caffeinate -u -t 1 & d=$(/usr/bin/python -c \"import Quartz; print Quartz.CGSessionCopyCurrentDictionary()\"); echo \"$d\" | grep -q \"OnConsoleKey = 0\" && { echo \"Needs to unlock manually\"; exit 1; }; echo \"$d\" | grep -q \"ScreenIsLocked = 1\" || { echo \"Mac is already unlocked\"; exit 1; }' | sh"

let checkStatusCommand = "echo 'd=$(/usr/bin/python -c \"import Quartz; print Quartz.CGSessionCopyCurrentDictionary()\"); echo \"$d\" | grep -q \"ScreenIsLocked = 1\" && { echo \"Failed to unlock Mac\"; exit 1; } || { echo \"Mac is unlocked\"; exit 0; }' | sh"


extension MacHost {
    @discardableResult func executeCmd(_ cmd: String) -> Result<String, NSError> {
        if cmd == "unlock" || cmd == "wake" {
            let command = getDetailCommand(cmd)
            return SshUtils.executeSshCmdWithPassword(command, host: host, username: user, password: password)
        }
        return .failure(NSError(domain:"MacKey", code: 121, userInfo: [NSLocalizedDescriptionKey : "This command is not supported."]))
    }
    
    func getDetailCommand(_ cmd: String) -> String {
        switch cmd {
        case "unlock":
            return wakeCommand + " && " + getUnlockCommand() + " && " + checkStatusCommand
        case "wake":
            return wakeCommand
        default:
            return cmd
        }
    }
    
    func getUnlockCommand() -> String {
        return "echo 'osascript -e '\"'\"'tell application \"System Events\"'\"'\"' -e '\"'\"'key code 123'\"'\"' -e '\"'\"'delay 0.1'\"'\"' -e '\"'\"'keystroke \"\(self.password)\"'\"'\"' -e '\"'\"'delay 0.5'\"'\"' -e '\"'\"'keystroke return'\"'\"' -e '\"'\"'delay 0.1'\"'\"' -e '\"'\"'end tell'\"'\"'' | sh"
    }
}
