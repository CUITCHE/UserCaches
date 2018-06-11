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
    private var _cacheContent = DiscardableCacheContent()
    private let semaphore = DispatchSemaphore(value: 1)
    private func _useCache<T>(closure: (_ cache: inout [String: CacheDecodable]) throws -> T) rethrows -> T {
        semaphore.wait()
        if !_cacheContent.beginContentAccess() {
            _cacheContent.reload()
        }
        defer {
            semaphore.signal()
            _cacheContent.endContentAccess()
        }
        return try closure(&_cacheContent._cache!)
    }

    #if os(Linux)
    private static func _filename() -> URL {
        if let filepath = Conf.cache_filepath.stringValue() {
            return URL(string: filepath)!
        } else {
            return URL(fileURLWithPath: CommandLine.arguments.first!).deletingLastPathComponent().appendingPathComponent("user.cache.default.standard.db")
        }
    }
    /// Returns a global instance of UserCaches named "user.cache.default.standard.db" by default at executed directory.
    /// Create it at cache_filepath if you specify the value of cache_filepath at conf.properties.
    open static var standard: UserCaches = try! .init(cachePath: UserCaches._filename())
    #else
    /// Returns a global instance of UserCaches named "user.cache.default.standard.db" at user.documents directory.
    open static var standard: UserCaches = try! .init(cachePath: FileManager.default.url(for: .documentDirectory,
                                                                                         in: .userDomainMask,
                                                                                         appropriateFor: nil,
                                                                                         create: true).appendingPathComponent("user.cache.default.standard.db"))
    #endif

    /// Create new cache file at the cachePath.
    ///
    /// - Parameter cachePath: A URL indicates cache filepath.
    /// - Throws: Throws an exception if creates failed.
    public init(cachePath: URL) throws {
        db = try CacheManager(cachePath: cachePath)
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
            if _useCache(closure: { $0[defaultName] != nil }), let v = value as? CacheDecodable {
                _useCache { $0[defaultName] = v }
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
        if let v = _useCache(closure: { $0[defaultName] }) as? T {
            return v
        }
        let cachedId = try db.findCacheKey(defaultName)
        guard cachedId != CacheNotFound else {  throw Error.noSuchValue }

        if let data = try db.selectCache(where: cachedId) {
            let instance = try T.initialize(fromCache: data)
            _useCache { $0[defaultName] = instance.instance }
            return instance.instance
        }
        throw Error.noSuchValue
    }

    /// Remove cache from disk with the key.
    ///
    /// - Parameter key: The key.
    /// - Throws: SQL Execute Error.
    open func removeKey(_ key: String) throws {
        let cachedId = try db.findCacheKey(key)
        if cachedId != CacheNotFound {
            _ = _useCache { $0.removeValue(forKey: key) }
            try db.removeCache(where: cachedId)
        }
    }

    /// Remove all of cache from disk and memory.
    ///
    /// - Throws: SQL Execute Error.
    open func removeAllKey() throws {
        _useCache {
            $0.removeAll()
        }
        try db.removeAllKey()
    }

    /// Remove all keys of standard global instance from disk. And clean memory cache.
    open static func resetStandardUserDefaults() {
        try? standard.removeAllKey()
    }
}
