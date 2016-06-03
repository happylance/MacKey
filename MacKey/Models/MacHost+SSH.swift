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
        if cmd == "unlock" || cmd == "wake" {
            let command = getDetailCommand(cmd)
            return SshUtils.executeSshCmdWithPassword(command, host: host, username: user, password: password)
        }
        return .Failure(NSError(domain:"MacKey", code: 121, userInfo: [NSLocalizedDescriptionKey : "This command is not supported."]))
    }
    
    func getDetailCommand(cmd: String) -> String {
        switch cmd {
        case "unlock":
            return getDetailCommand("wake") +
                "&& echo 'osascript -e '\"'\"'tell application \"System Events\"'\"'\"' -e '\"'\"'key code 123'\"'\"' -e '\"'\"'delay 0.1'\"'\"' -e '\"'\"'keystroke \"\(self.password)\"'\"'\"' -e '\"'\"'delay 0.5'\"'\"' -e '\"'\"'keystroke return'\"'\"' -e '\"'\"'end tell'\"'\"'' | sh"
        case "wake":
            return "echo 'caffeinate  -u -t 1 & d=$(/usr/bin/python -c \"import Quartz; print Quartz.CGSessionCopyCurrentDictionary()\");echo \"$d\" | grep -q \"OnConsoleKey = 0\" && { echo \"Needs to unlock manually\"; return; };echo \"$d\" | grep -q \"ScreenIsLocked = 1\" || { echo \"Mac is already unlocked\"; };' | sh"
        default:
            return cmd;
        }
    }
}