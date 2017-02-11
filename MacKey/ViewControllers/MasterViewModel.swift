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
    let selectedIndex$: Driver<(IndexPath, HostsState)>
    let selectedCellStatusUpdate$: Driver<String>
    
    init(itemSelected$: Driver<IndexPath>,
         sleepButtonTapped$: Driver<String>) {
        let storeState$ = store.observable.asDriver()
        
        selectedIndex$ = itemSelected$.withLatestFrom(storeState$) { ($0, $1.hostsState) }
        
        let enterForeground$: Observable<Void> = NotificationCenter
            .default.rx.notification(.UIApplicationWillEnterForeground)
            .map { _ in }
        
        let startConnection$ = Observable
            .of(Observable.just(), // for didFinishLaunching
                enterForeground$,
                itemSelected$.asObservable().map { _ in })
            .merge()
        
        let unlockStatus$ = startConnection$.withLatestFrom(store.observable.asObservable())
            .map { $0.hostsState }
            .filter { $0.allHosts.keys.contains($0.latestHostAlias) }
            .map { $0.allHosts[$0.latestHostAlias]! }
            .flatMapLatest { host in MacUnlockService.wakeUp(host).map { (host, $0) } }
            .observeOn(MainScheduler.instance)
            .flatMapLatest { (host, status) -> Observable<(HostInfo, UnlockStatus)> in
                switch status {
                case .connectedAndNeedsUnlock:
                    return MacUnlockService.runTouchID(for: host).startWith(status).map { (host, $0) }
                default:
                    return Observable.just((host, status))
                }
            }
            .flatMapLatest { (host, status) -> Observable<UnlockStatus> in
                switch status {
                case .unlocking:
                    return MacUnlockService.unlock(host).startWith(status)
                default:
                    return Observable.just(status)
                }
            }
        
        let sleepStatus$ = sleepButtonTapped$
            .filter { $0 != "" }
            .withLatestFrom(storeState$) { $1.hostsState.allHosts[$0] }
            .asObservable()
            .filter { $0 != nil }.map { $0! }
            .flatMapLatest { MacUnlockService.sleep($0) }
        
        let connectionStatus$ = Observable.of(unlockStatus$, sleepStatus$)
            .merge()
            .map {
                switch $0 {
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
            .asDriver(onErrorJustReturn: "")
        
        let statusWhenEnterBackground$: Driver<String> = NotificationCenter.default.rx
            .notification(.UIApplicationDidEnterBackground)
            .map { _ in "" }
            .asDriver(onErrorJustReturn: "")
        
        selectedCellStatusUpdate$ = Driver.of(connectionStatus$, statusWhenEnterBackground$)
            .merge()
    }
}
    