//
//  BinarySearch.swift
//  Commands
//
//  Created by Liu Liang on 5/8/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

// From http://stackoverflow.com/questions/31904396/swift-binary-search-for-standard-array/33674192#33674192
extension Collection {
    /// Finds such index N that predicate is true for all elements up to
    /// but not including the index N, and is false for all elements
    /// starting with index N.
    /// Behavior is undefined if there is no such N.
    func binarySearch(predicate: (Iterator.Element) -> Bool) -> Index {
        var low = startIndex
        var high = endIndex
        while low != high {
            let mid = index(low, offsetBy: distance(from: low, to: high)/2)
            if predicate(self[mid]) {
                low = index(after: mid)
            } else {
                high = mid
            }
        }
        return low
    }
}
