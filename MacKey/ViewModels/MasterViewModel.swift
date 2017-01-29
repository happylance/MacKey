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
    let hostSelected: Driver<Bool>
    let stateDiff: Driver<(HostsState, HostsState)>
    let selectedIndex: Driver<(IndexPath, HostsState)>
    
    init(itemSelected: Driver<IndexPath>) {
        let storeState = store.observable.asDriver()
        hostSelected = storeState.map { $0.hostsState.hostSelected }
            .filter { $0 }

        let hostsState = storeState.map { $0.hostsState }
            .distinctUntilChanged { $0.allHosts == $1.allHosts }
        
        stateDiff = Driver.zip([hostsState, hostsState.skip(1)]) {
            (stateArray) -> (HostsState, HostsState) in
            return (stateArray[0], stateArray[1])
        }

        selectedIndex = itemSelected.withLatestFrom(storeState) { ($0, $1.hostsState) }
    }
}
    
