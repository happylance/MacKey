//
//  MasterViewModel.swift
//  MacKey
//
//  Created by Liu Liang on 28/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import ReactiveReSwift
import RxSwift
import RxCocoa

class MasterViewModel {
    // - MARK: Inputs
    let unlockRequest: AnyObserver<IndexPath>
    let sleepRequests: AnyObserver<String>
    let hostsState: AnyObserver<HostsState>
    
    // - MARK: Outputs
    let hasSelectedCell$: Observable<Bool>
    let selectedIndex$: Observable<(IndexPath, HostsState)>
    let selectedCellStatusUpdate$: Observable<String>
    
    init() {
        let _unlockRequest$ = PublishSubject<IndexPath>()
        unlockRequest = _unlockRequest$.asObserver()
        
        let _sleepRequests$ = PublishSubject<String>()
        sleepRequests = _sleepRequests$.asObserver()
        
        let _hostsState$ = PublishSubject<HostsState>()
        hostsState = _hostsState$.asObserver()
        
        hasSelectedCell$ = _hostsState$
            .map { $0.latestHostAlias.count > 0 }
            .distinctUntilChanged()
        
        selectedIndex$ = _unlockRequest$.withLatestFrom(_hostsState$) { ($0, $1) }
        
        let enterForeground$: Observable<Void> = NotificationCenter
            .default.rx.notification(.UIApplicationWillEnterForeground)
            .map { _ in }
        
        let startConnection$ = Observable
            .of(Observable.just(()), // for didFinishLaunching
                enterForeground$,
                _unlockRequest$.asObservable().map { _ in })
            .merge()
        
        let unlockStatus$ = startConnection$.withLatestFrom(_hostsState$)
            .filter { $0.allHosts.keys.contains($0.latestHostAlias) }
            .map { $0.allHosts[$0.latestHostAlias]! }
            .flatMapLatest { host in MacUnlockService.wakeUp(host).map { (host, $0) } }
            .observeOn(MainScheduler.instance)
            .flatMapLatest { (host, status) -> Observable<(HostInfo, UnlockStatus)> in
                switch status {
                case .connectedAndNeedsUnlock:
                    if host.requireTouchID {
                        return MacUnlockService.runTouchID(for: host).map { (host, $0) }
                    } else {
                        return .just((host, .unlocking))
                    }
                default:
                    return .just((host, status))
                }
            }
            .flatMapLatest { (host, status) -> Observable<(HostInfo, UnlockStatus)> in
                switch status {
                case .unlocking:
                    return MacUnlockService.unlock(host).map { (host, $0) }
                default:
                    return Observable.just((host, status))
                }
            }
            .flatMapLatest { (host, status) -> Observable<UnlockStatus> in
                switch status {
                case .connectedWithInfo(let info):
                    if info.contains("Failed") {
                        return MacUnlockService.checkStatus(host)
                    }
                default:
                    break
                }
                return Observable.just(status)
        }
        
        let sleepStatus$ = _sleepRequests$
            .filter { $0 != "" }
            .withLatestFrom(_hostsState$) { $1.allHosts[$0] }
            .asObservable()
            .filter { $0 != nil }.map { $0! }
            .flatMapLatest { MacUnlockService.sleep($0) }
        
        let connectionStatus$ = Observable.of(unlockStatus$, sleepStatus$)
            .merge()
            .map { status -> String in
                switch status {
                case .connecting:
                    return "Connecting..."
                case .connectedAndNeedsUnlock:
                    return "Require touch ID"
                case let .connectedWithInfo(info):
                    return info
                case let .error(error):
                    return error
                case .unlocking:
                    return "Unlocking..."
                }
            }
        
        let statusWhenEnterBackground$: Observable<String> = NotificationCenter.default.rx
            .notification(.UIApplicationDidEnterBackground)
            .map { _ in "" }
        
        selectedCellStatusUpdate$ = Observable.of(connectionStatus$, statusWhenEnterBackground$)
            .merge()
            .map { $0.replacingOccurrences(of: "\n", with: "") }
    }
}
    
