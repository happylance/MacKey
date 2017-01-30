//
//  MasterViewModel.swift
//  MacKey
//
//  Created by Liu Liang on 28/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import Foundation
import ReactiveReSwift
import RxSwift
import RxCocoa

class MasterViewModel {
    let stateDiff: Driver<(HostsState, HostsState)>
    let selectedIndex: Driver<(IndexPath, HostsState)>
    let wakeUpResonse: Observable<WakeUpResponse>
    let needsUnlock: Observable<Bool>
    let selectedCellStatus: Driver<String>
    
    init(itemSelected: Driver<IndexPath>) {
        let storeState = store.observable.asDriver()
        let hostsState = storeState.map { $0.hostsState }
            .distinctUntilChanged { $0.allHosts == $1.allHosts }
        
        stateDiff = Driver.zip([hostsState, hostsState.skip(1)]) {
            (stateArray) -> (HostsState, HostsState) in
            return (stateArray[0], stateArray[1])
        }

        selectedIndex = itemSelected.withLatestFrom(storeState) { ($0, $1.hostsState) }
        
        wakeUpResonse = store.observable.asObservable()
            .map { $0.hostsState }
            .distinctUntilChanged { $0.latestConnectionTime == $1.latestConnectionTime }
            .filter { $0.latestConnectionTime != nil && $0.allHosts.keys.contains($0.latestHostAlias) }
            .map { $0.allHosts[$0.latestHostAlias]! }
            .flatMapLatest { MacUnlockService().wakeUp(host: $0) }
            .observeOn(MainScheduler.instance)
            .shareReplay(1)
  
        needsUnlock = wakeUpResonse
            .filter {
                switch $0 {
                case .connectedAndNeedsUnlock: return true
                default: return false
                }
            }
            .map { _ in true }
        
        selectedCellStatus = wakeUpResonse
            .map {
                switch $0 {
                case .connecting:
                    return "Connecting..."
                case .connectedAndNeedsUnlock:
                    return ""
                case let .connectedWithInfo(info):
                    return info
                case let .connectionError(error):
                    return error
                }
            }
            .asDriver(onErrorJustReturn: "")
    }
}
    
