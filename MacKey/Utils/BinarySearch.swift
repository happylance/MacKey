//
//  BinarySearch.swift
//  Commands
//
//  Created by Liu Liang on 5/8/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import Foundation

// From http://stackoverflow.com/questions/31904396/swift-binary-search-for-standard-array/33674192#33674192
extension CollectionType where Index: RandomAccessIndexType {
    
    /// Finds such index N that predicate is true for all elements up to
    /// but not including the index N, and is false for all elements
    /// starting with index N.
    /// Behavior is undefined if there is no such N.
    func binarySearch(predicate: Generator.Element -> Bool) -> Index {
        var low = startIndex
        var high = endIndex
        while low != high {
            let mid = low.advancedBy(low.distanceTo(high) / 2)
            if predicate(self[mid]) {
                low = mid.advancedBy(1)
            } else {
                high = mid
            }
        }
        return low
    }
    
}
