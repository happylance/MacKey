//
//  AppHelper.swift
//  MacKey
//
//  Created by Liu Liang on 5/6/18.
//  Copyright © 2018 Liu Liang. All rights reserved.
//

import Foundation
import RxSwift

class AppHelper {
    let latestHostAliasSkipFirst: Observable<String>
    let supportSkippingTouchIDSkipFirst: Observable<Bool>
    let supportSleepModeSkipFirst: Observable<Bool>
    
    init(state: Observable<State>) {
        latestHostAliasSkipFirst = state.map { $0.hostsState.latestHostAlias }
            .distinctUntilChanged().skip(1)
        
        supportSkippingTouchIDSkipFirst = state.map { $0.supportSkippingTouchID }
            .distinctUntilChanged().skip(1)
        
        supportSleepModeSkipFirst = state.map { $0.supportSleepMode }
            .distinctUntilChanged().skip(1)
    }
}
