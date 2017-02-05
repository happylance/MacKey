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

class MacUnlockService {
    
    static func wakeUp(_ host: HostInfo) -> Observable<UnlockStatus> {
        let cmd = getDetailCommand("wake", for: host)
        return SSHService().executeSshCommand(cmd, host: host)
            .map { $0 == "" ? .connectedAndNeedsUnlock : .connectedWithInfo(info: $0) }
            .catchError { error in
                guard let error = error as? SSHSessionError else {
                    return Observable.just(.error(error: ""))
                }
                switch error {
                case let .failedWithResponse(response):
                    return Observable.just(.connectedWithInfo(info: response))
                default: return Observable.just(.error(error: error.debugDescription))
                }
            }
            .startWith(.connecting)
    }
    
    static func runTouchID(for host: HostInfo) -> Observable<UnlockStatus> {
        return TouchIDService.runTouchID(for: host).map { (success, error) in
            return success ? .unlocking : UnlockStatus.error(error: TouchIDService.getErrorMessage(error))
        }
    }
    
    static func unlock(_ host: HostInfo) -> Observable<UnlockStatus> {
        let cmd = getDetailCommand("unlock", for: host)
        return SSHService().executeSshCommand(cmd, host: host)
            .map { .connectedWithInfo(info: $0) }
            .catchError { error in
                guard let error = error as? SSHSessionError else {
                    return Observable.just(.error(error: ""))
                }
                switch error {
                case let .failedWithResponse(response):
                    return Observable.just(.connectedWithInfo(info: response))
                default: return Observable.just(.error(error: error.debugDescription))
                }
            }
    }
    
    static func sleep(_ host: HostInfo) -> Observable<UnlockStatus> {
        let cmd = getDetailCommand("sleep", for: host)
        return SSHService().executeSshCommand(cmd, host: host)
            .map { .connectedWithInfo(info: $0) }
            .catchError { error in
                guard let error = error as? SSHSessionError else {
                    return Observable.just(.error(error: ""))
                }
                switch error {
                case let .failedWithResponse(response):
                    return Observable.just(.connectedWithInfo(info: response))
                default: return Observable.just(.error(error: error.debugDescription))
                }
            }
            .startWith(.connecting)
    }
    
    private static let wakeCommand = "echo 'caffeinate -u -t 1 & d=$(/usr/bin/python -c \"import Quartz; print Quartz.CGSessionCopyCurrentDictionary()\"); echo \"$d\" | grep -q \"OnConsoleKey = 0\" && { echo \"Needs to unlock manually\"; exit 1; }; echo \"$d\" | grep -q \"ScreenIsLocked = 1\" || { echo \"Mac is already unlocked\"; exit 1; }' | sh"
    
    private static let checkStatusCommand = "echo 'd=$(/usr/bin/python -c \"import Quartz; print Quartz.CGSessionCopyCurrentDictionary()\"); echo \"$d\" | grep -q \"ScreenIsLocked = 1\" && { echo \"Failed to unlock Mac\"; exit 1; } || { echo \"Mac is unlocked\"; exit 0; }' | sh"
    
    private static func getDetailCommand(_ cmd: String, for host: HostInfo) -> String {
        switch cmd {
        case "unlock":
            return wakeCommand + " && " + getUnlockCommand(for: host) + " && " + checkStatusCommand
        case "wake":
            return wakeCommand
        case "sleep":
            return "osascript -e 'tell application \"Finder\" to sleep'"
        default:
            return cmd
        }
    }
    
    private static func getUnlockCommand(for host: HostInfo) -> String {
        return "echo 'osascript -e '\"'\"'tell application \"System Events\"'\"'\"' -e '\"'\"'key code 123'\"'\"' -e '\"'\"'delay 0.1'\"'\"' -e '\"'\"'keystroke \"\(host.password)\"'\"'\"' -e '\"'\"'delay 0.5'\"'\"' -e '\"'\"'keystroke return'\"'\"' -e '\"'\"'delay 0.1'\"'\"' -e '\"'\"'end tell'\"'\"'' | sh"
    }

}
