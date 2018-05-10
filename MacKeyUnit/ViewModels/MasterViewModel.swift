//
//  MasterViewModel.swift
//  MacKey
//
//  Created by Liu Liang on 28/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import RxSwift
import RxCocoa

protocol MacUnlockUseCase {
    func wakeUp(_ host: HostInfo) -> Observable<UnlockStatus>
    func runTouchID(for host: HostInfo) -> Observable<UnlockStatus>
    func unlock(_ host: HostInfo) -> Observable<UnlockStatus>
    func checkStatus(_ host: HostInfo) -> Observable<UnlockStatus>
    func sleep(_ host: HostInfo) -> Observable<UnlockStatus>
}

class MasterViewModel {
    // - MARK: Inputs
    let unlockRequest = PublishRelay<IndexPath>()
    let sleepRequests = PublishRelay<String>()
    let hostsState = PublishRelay<HostsState>()
    let enterForeground = PublishRelay<()>()
    let enterBackground = PublishRelay<()>()
    
    // - MARK: Outputs
    let hasSelectedCell$: Observable<Bool>
    let selectedIndex$: Observable<(IndexPath, HostsState)>
    let selectedCellStatusUpdate$: Observable<String>
    
    init(macUnlockService: MacUnlockUseCase) {
        
        hasSelectedCell$ = hostsState
            .map { $0.latestHostAlias.count > 0 }
            .distinctUntilChanged()
        
        selectedIndex$ = unlockRequest.withLatestFrom(hostsState) { ($0, $1) }
        
        let startConnection$ = Observable
            .of(Observable.just(()), // for didFinishLaunching
                enterForeground.asObservable(),
                unlockRequest.map { _ in })
            .merge()
        
        let unlockStatus$ = startConnection$.withLatestFrom(hostsState)
            .filter { $0.allHosts.keys.contains($0.latestHostAlias) }
            .map { $0.allHosts[$0.latestHostAlias]! }
            .flatMapLatest { host in macUnlockService.wakeUp(host).map { (host, $0) } }
            .observeOn(MainScheduler.instance)
            .flatMapLatest { (host, status) -> Observable<(HostInfo, UnlockStatus)> in
                switch status {
                case .connectedAndNeedsUnlock:
                    if host.requireTouchID {
                        return macUnlockService.runTouchID(for: host).map { (host, $0) }
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
                    return macUnlockService.unlock(host).map { (host, $0) }
                default:
                    return Observable.just((host, status))
                }
            }
            .flatMapLatest { (host, status) -> Observable<UnlockStatus> in
                switch status {
                case .connectedWithInfo(let info):
                    if info.contains("Failed") {
                        return macUnlockService.checkStatus(host)
                    }
                default:
                    break
                }
                return Observable.just(status)
        }
        
        let sleepStatus$ = sleepRequests
            .filter { $0 != "" }
            .withLatestFrom(hostsState) { $1.allHosts[$0] }
            .asObservable()
            .filter { $0 != nil }.map { $0! }
            .flatMapLatest { macUnlockService.sleep($0) }
        
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
        
        let statusWhenEnterBackground$: Observable<String> = enterBackground
            .map { _ in "" }
        
        selectedCellStatusUpdate$ = Observable.of(connectionStatus$, statusWhenEnterBackground$)
            .merge()
            .map { $0.replacingOccurrences(of: "\n", with: "") }
    }
}
    
