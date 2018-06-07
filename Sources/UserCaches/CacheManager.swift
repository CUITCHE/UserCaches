//
//  CacheManager.swift
//  UserCaches
//
//  Created by hejunqiu on 2018/6/3.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import Foundation
import SQLite

let CacheNotFound = Int64.max

class CacheManager {
    // MARK: database field
    private let _cache = Table("cache")
    private let key    = Expression<String>("k")
    private let value  = Expression<Data>("v")
    let db: Connection

    enum Error: Swift.Error {
        case initialize(String)
    }

    init(cachePath path: URL) throws {
        #if os(Linux)
        db = try Connection(path.path)
        #else
        db = try Connection(path.absoluteString)
        #endif
        try db.run(_cache.create(ifNotExists: true) { t in
            t.column(key)
            t.column(value)
        })
    }

    func findCacheKey(_ key: String) throws -> Int64 {
        for rowid in try db.prepare(_cache.select(SQLite.rowid).where(self.key == key)) {
            return try rowid.get(SQLite.rowid)
        }
        return CacheNotFound
    }

    func insertCache(_ value: Data, forKey key: String) throws {
        try db.run(_cache.insert(self.key <- key, self.value <- value))

    }

    func updateCache(_ value: Data, `where` rowid: Int64) throws {
        try db.run(_cache.filter(SQLite.rowid == rowid).update(self.value <- value))
    }

    func removeCache(`where` rowid: Int64) throws {
        try db.run(_cache.filter(SQLite.rowid == rowid).delete())

    }

    func selectCache(where rowid: Int64) throws -> Data? {
        for value in try db.prepare(_cache.select(self.value).where(SQLite.rowid == rowid)) {
            return try value.get(self.value)
        }
        return nil
    }

    func removeAllKey() throws {
        try db.run(_cache.delete())
    }
}
