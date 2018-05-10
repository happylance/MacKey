//
//  UnlockStatus.swift
//  MacKey
//
//  Created by Liu Liang on 5/8/18.
//  Copyright © 2018 Liu Liang. All rights reserved.
//

enum UnlockStatus {
    case connecting
    case connectedAndNeedsUnlock
    case connectedWithInfo(info: String)
    case error(error: String)
    case unlocking
}
