//
//  Config.swift
//  MacKey
//
//  Created by Liu Liang on 5/9/18.
//  Copyright © 2018 Liu Liang. All rights reserved.
//

import Foundation

struct Config {
    static let sleepModeProductID = "com.nlprliu.MacKey.pro"
    static let skipTouchIDProductID = "com.nlprliu.MacKey.skipTouchID"
    static var forUITesting: Bool {
        return ProcessInfo.processInfo.arguments.contains("UI-TESTING")
    }
}
