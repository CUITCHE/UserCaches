//
//  DiscardableCacheContent.swift
//  UserCaches
//
//  Created by He,Junqiu on 2018/6/11.
//

import Foundation

class DiscardableCacheContent: NSDiscardableContent {
    func beginContentAccess() -> Bool {
        if _cache == nil {
            return false
        }
        _accessCount += 1
        return true
    }

    func endContentAccess() {
        if _accessCount > 0 {
            _accessCount -= 1
        }
    }

    func discardContentIfPossible() {
        if _accessCount == 0 {
            _cache = nil
        }
    }

    func isContentDiscarded() -> Bool {
        return _cache == nil
    }

    /// Reload the cache and set 1 to _accessCount
    func reload() {
        if _cache == nil {
            _cache = [String: CacheDecodable]()
            _accessCount = 1
        }
    }

    var _cache: [String: CacheDecodable]! = [String: CacheDecodable]()
    var _accessCount = 0
}
