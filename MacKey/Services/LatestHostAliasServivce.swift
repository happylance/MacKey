//
//  LatestHostAliasServivce.swift
//  MacKey
//
//  Created by Liu Liang on 15/01/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import Foundation

fileprivate let latestHostAliasKey = "latestHostAlias"

class LatestHostAliasServivce {
    static var alias: String {
        get {
            return UserDefaults.standard.string(forKey: latestHostAliasKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: latestHostAliasKey)
            UserDefaults.standard.synchronize()
        }
    }
}
