//
//  UserCaches.swift
//  UserCaches
//
//  Created by hejunqiu on 2018/6/3.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import Foundation

/// Usage as UserDefaults.
open class UserCaches {
    public enum Error: Swift.Error {
        case noSuchValue
    }
    let db: CacheManager
    private var _cache = [String: CacheDecodable]()

    #if os(Linux)
    /// Returns a global instance of UserCaches named "user.cache.default.standard.db" at executed directory.
    open static var standard: UserCaches = try! .init(suiteName: "./user.cache.default.standard")
    #else
    /// Returns a global instance of UserCaches named "user.cache.default.standard.db" at user.documents directory.
    open static var standard: UserCaches = try! .init(suiteName: "user.cache.default.standard")
    #endif

    /// Create new cache named `suiteName` at user.documents directory.
    ///
    /// - Parameter suiteName: domain `suiteName`
    /// - Throws: Throws an exception if creates failed.
    public init(suiteName: String) throws {
        db = try CacheManager(cacheName: suiteName)
    }

    /// Insert or update if exists cache for the given key.
    ///
    /// - Parameters:
    ///   - value: A value that defer to `CacheEncodable`
    ///   - defaultName: The key associated with value.
    /// - Throws:
    ///   - SQL Execute Error.
    ///   - `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    ///   - An error if any value throws an error during encoding.
    open func set(_ value: CacheEncodable, forKey defaultName: String) throws {
        let cachedId = try db.findCacheKey(defaultName)
        if cachedId != CacheNotFound {
            try db.updateCache(try value.toData(), where: cachedId)
            if _cache[defaultName] != nil, let v = value as? CacheDecodable {
                _cache[defaultName] = v
            }
        } else {
            try db.insertCache(value.toData(), forKey: defaultName)
        }
    }

    /// Return the cache value associated with key if exists.
    ///
    /// - Parameter defaultName: The associated key.
    /// - Returns: Return the value if exists.
    /// - Throws:
    ///   - Throws Error.noSuchValue if has no such value with the associated key.
    ///   - Initialize instance of T failed.
    ///   - `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid JSON.
    ///   - An error if any value throws an error during decoding.
    open func value<T: CacheDecodable>(forKey defaultName: String) throws -> T {
        if let v = _cache[defaultName] as? T {
            return v
        }
        let cachedId = try db.findCacheKey(defaultName)
        guard cachedId != CacheNotFound else {  throw Error.noSuchValue }

        if let data = try db.selectCache(where: cachedId) {
            let instance = try T.initialize(fromCache: data)
            _cache[defaultName] = instance.instance
            return instance.instance
        }
        throw Error.noSuchValue
    }

    /// Remove recorde from disk.
    ///
    /// - Parameter key: The key.
    /// - Throws: SQL Execute Error.
    open func removeKey(_ key: String) throws {
        let cachedId = try db.findCacheKey(key)
        if cachedId != CacheNotFound {
            _cache.removeValue(forKey: key)
            try db.removeCache(where: cachedId)
        }
    }

    /// Remove all keys of standard global instance from disk
    open static func resetStandardUserDefaults() {
        standard._cache.removeAll()
        try? standard.db.removeAllKey()
    }
}
