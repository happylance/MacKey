//
//  MacUnlockService.swift
//  MacKey
//
//  Created by Liu Liang on 29/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import RxSwift
import RxCocoa

enum UnlockStatus {
    case connecting
    case connectedAndNeedsUnlock
    case connectedWithInfo(info: String)
    case error(error: String)
    case unlocking
}

private func convertError(_ error: Error) -> Observable<UnlockStatus> {
    guard let error = error as? SSHSessionError else {
        return Observable.just(.error(error: ""))
    }
    switch error {
    case let .failedWithResponse(response):
        dlog(response)
        return Observable.just(.connectedWithInfo(info: response))
    default: return Observable.just(.error(error: error.debugDescription))
    }
}

class MacUnlockService {
    
    static func wakeUp(_ host: HostInfo) -> Observable<UnlockStatus> {
        let cmd = getDetailCommand("wake", for: host)
        return SSHService().executeSshCommand(cmd, host: host)
            .map { $0 == "" ? .connectedAndNeedsUnlock : .connectedWithInfo(info: $0) }
            .catchError { convertError($0) }
            .startWith(.connecting)
    }
    
    static func runTouchID(for host: HostInfo) -> Observable<UnlockStatus> {
        return TouchIDService.runTouchID(for: host).map { (success, error) in
            return success ? .unlocking : UnlockStatus.error(error: TouchIDService.getErrorMessage(error))
        }
    }
    
    static func unlock(_ host: HostInfo) -> Observable<UnlockStatus> {
        return execCommand("unlock", host: host)
            .catchError { convertError($0) }
    }
    
    static func checkStatus(_ host: HostInfo) -> Observable<UnlockStatus> {
        return execCommand("checkStatus", host: host)
    }
    
    static func sleep(_ host: HostInfo) -> Observable<UnlockStatus> {
        return execCommand("sleep", host: host)
            .startWith(.connecting)
    }
    
    static private func execCommand(_ command: String, host: HostInfo) -> Observable<UnlockStatus> {
        let detailCommand = getDetailCommand(command, for: host)
        return SSHService().executeSshCommand(detailCommand, host: host)
            .map { .connectedWithInfo(info: dlog($0)) }
            .catchError { convertError($0) }
    }
    
    private static let wakeCommand = "echo 'caffeinate -u -t 1 & d=$(/usr/bin/python -c \"import Quartz; print Quartz.CGSessionCopyCurrentDictionary()\"); echo \"$d\" | grep -q \"OnConsoleKey = 0\" && { echo \"Needs to unlock manually\"; exit 1; }; echo \"$d\" | grep -q \"ScreenIsLocked = 1\" || { echo \"Mac is already unlocked\"; exit 1; }' | sh"
    
    private static let checkStatusCommand = "echo 'd=$(/usr/bin/python -c \"import Quartz; print Quartz.CGSessionCopyCurrentDictionary()\"); echo \"$d\" | grep -q \"ScreenIsLocked = 1\" && { echo \"Failed to unlock Mac\"; exit 1; } || { echo \"Mac is unlocked\"; exit 0; }' | sh"
    
    private static func getDetailCommand(_ cmd: String, for host: HostInfo) -> String {
        switch cmd {
        case "checkStatus":
            return checkStatusCommand
        case "unlock":
            return wakeCommand + " && " + getUnlockCommand(for: host) + " && " + checkStatusCommand
        case "wake":
            return wakeCommand
        case "sleep":
            return "pmset displaysleepnow"
        default:
            return cmd
        }
    }
    
    private static func getUnlockCommand(for host: HostInfo) -> String {
        return "echo 'osascript -e '\"'\"'tell application \"System Events\"'\"'\"' -e '\"'\"'key code 123'\"'\"' -e '\"'\"'delay 0.1'\"'\"' -e '\"'\"'keystroke \"\(host.password)\"'\"'\"' -e '\"'\"'delay 0.5'\"'\"' -e '\"'\"'keystroke return'\"'\"' -e '\"'\"'end tell'\"'\"'' | sh"
    }

}
