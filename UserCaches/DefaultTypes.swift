//
//  DefaultTypes.swift
//  UserCaches
//
//  Created by hejunqiu on 2018/6/3.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import Foundation

public enum TypeHeader: UInt32 {
    case bool      = 0b1000_0000_0000_0000_0000_0000_0000_0000
    case int       = 0b1000_1000_0000_0000_0000_0000_0000_0000
    case int64     = 0b1001_0000_0000_0000_0000_0000_0000_0000
    case uint      = 0b1001_1000_0000_0000_0000_0000_0000_0000
    case uint64    = 0b1010_0000_0000_0000_0000_0000_0000_0000
    case float     = 0b1010_1000_0000_0000_0000_0000_0000_0000
    case double    = 0b1011_0000_0000_0000_0000_0000_0000_0000
    case string    = 0b1011_1000_0000_0000_0000_0000_0000_0000
    case data      = 0b1100_0000_0000_0000_0000_0000_0000_0000
    case date      = 0b1100_1000_0000_0000_0000_0000_0000_0000
    case array     = 0b1101_0000_0000_0000_0000_0000_0000_0000
    case dictionay = 0b1101_1000_0000_0000_0000_0000_0000_0000
    case codable   = 0b1110_0000_0000_0000_0000_0000_0000_0000
}

extension Data {
    func subrangeToEnd(withOffset offset: Int) -> Data {
        return self[self.startIndex.advanced(by: offset)...]
    }
}

@inline(__always)
private func _initialize<T: Numeric>(fromCache data: Data, header: TypeHeader) -> (instance: T, restData: Data) {
    assert(data.count >= MemoryLayout<UInt32>.size + MemoryLayout<T>.size)
    var k: UInt32 = 0
    (data as NSData).getBytes(&k, length: MemoryLayout<UInt32>.size)
    assert(k == header.rawValue)

    var v: T = 0
    let data = data.subrangeToEnd(withOffset: MemoryLayout<UInt32>.size)
    (data as NSData).getBytes(&v, length: MemoryLayout<T>.size)
    return (v, data.subrangeToEnd(withOffset: MemoryLayout<T>.size))
}

@inline(__always)
private func _toData<T: Numeric>(value: T, header: TypeHeader) -> Data {
    var v = value
    var k = header.rawValue
    let header = Data(bytes: &k, count: MemoryLayout.size(ofValue: k))
    let data = header + Data(bytes: &v, count: MemoryLayout<T>.size)
    return data
}

extension Bool: CacheCodable {
    public static func initialize(fromCache data: Data) -> (instance: Bool, restData: Data) {
        assert(data.count >= 4)
        var v: UInt32 = 0
        (data as NSData).getBytes(&v, length: MemoryLayout.size(ofValue: v))
        assert(v & TypeHeader.bool.rawValue == TypeHeader.bool.rawValue)
        return (data[data.startIndex] == 1, data.subrangeToEnd(withOffset: MemoryLayout.size(ofValue: v)))
    }

    public func toData() -> Data {
        var v = (self ? 1 : 0) | TypeHeader.bool.rawValue
        let data = Data(bytes: &v, count: MemoryLayout<UInt32>.size)
        return data
    }
}

extension Int: CacheCodable {
    public static func initialize(fromCache data: Data) -> (instance: Int, restData: Data) {
        return _initialize(fromCache: data, header: .int)
    }

    public func toData() -> Data {
        return _toData(value: self, header: .int)
    }
}

extension Int64: CacheCodable {
    public static func initialize(fromCache data: Data) -> (instance: Int64, restData: Data) {
        return _initialize(fromCache: data, header: .int)
    }

    public func toData() -> Data {
        return _toData(value: self, header: .int)
    }
}

extension UInt: CacheCodable {
    public static func initialize(fromCache data: Data) -> (instance: UInt, restData: Data) {
        return _initialize(fromCache: data, header: .uint)
    }

    public func toData() -> Data {
        return _toData(value: self, header: .uint)
    }
}

extension UInt64: CacheCodable {
    public static func initialize(fromCache data: Data) -> (instance: UInt64, restData: Data) {
        return _initialize(fromCache: data, header: .uint)
    }

    public func toData() -> Data {
        return _toData(value: self, header: .uint)
    }
}

extension Float: CacheCodable {
    public static func initialize(fromCache data: Data) -> (instance: Float, restData: Data) {
        return _initialize(fromCache: data, header: .float)
    }

    public func toData() -> Data {
        return _toData(value: self, header: .float)
    }
}

extension Double: CacheCodable {
    public static func initialize(fromCache data: Data) -> (instance: Double, restData: Data) {
        return _initialize(fromCache: data, header: .double)
    }

    public func toData() -> Data {
        return _toData(value: self, header: .double)
    }
}

extension Date: CacheCodable {
    public static func initialize(fromCache data: Data) -> (instance: Date, restData: Data) {
        let process: (instance: TimeInterval, restData: Data) = _initialize(fromCache: data, header: .date)
        return (Date(timeIntervalSince1970: process.instance), process.restData)
    }

    public func toData() -> Data {
        return _toData(value: timeIntervalSince1970, header: .date)
    }
}

@inline(__always)
private func _initialize_countable_case(_ data: Data, header: TypeHeader) -> (data: Data, count: Int) {
    assert(data.count >= MemoryLayout.size(ofValue: header.rawValue) + MemoryLayout<Int>.size)
    var k: UInt32 = 0
    (data as NSData).getBytes(&k, length: MemoryLayout<UInt32>.size)
    assert(k == header.rawValue)

    var data = data.subrangeToEnd(withOffset: MemoryLayout<UInt32>.size)
    var cnt = 0
    (data as NSData).getBytes(&cnt, length: MemoryLayout<Int>.size)
    data = data.subrangeToEnd(withOffset: MemoryLayout<Int>.size)
    return (data, cnt)
}

@inline(__always)
private func _todata_countable_case(value: Data, count: Int, header: TypeHeader) -> Data {
    var k = header.rawValue
    let header = Data(bytes: &k, count: MemoryLayout.size(ofValue: k))
    var count = count
    let countField = Data(bytes: &count, count: MemoryLayout.size(ofValue: count))
    return header + countField + value
}

extension String: CacheCodable {
    public static func initialize(fromCache data: Data) -> (instance: String, restData: Data) {
        let data = _initialize_countable_case(data, header: .string)
        guard let v = String(data: data.data[..<data.data.startIndex.advanced(by: data.count)], encoding: .utf8) else {
            assertionFailure("Get String from cache data(\(data)) failed.")
            return ("", data.data[data.data.startIndex...])
        }
        return (v, data.data.subrangeToEnd(withOffset: data.count))
    }

    public func toData() -> Data {
        guard let data = self.data(using: .utf8) else {
            print("Save String(\(self)) Cache failed.")
            return Data()
        }
        return _todata_countable_case(value: data, count: data.count, header: .string)
    }
}

extension Data: CacheCodable {
    public static func initialize(fromCache data: Data) -> (instance: Data, restData: Data) {
        let data = _initialize_countable_case(data, header: .data)
        return (data.data[..<data.data.startIndex.advanced(by: data.count)],
                data.data.subrangeToEnd(withOffset: data.count))
    }

    public func toData() -> Data {
        return _todata_countable_case(value: self, count: count, header: .data)
    }
}

extension Array: CacheEncodable where Element: CacheEncodable {
    public func toData() throws -> Data {
        var data = Data()
        try forEach { data.append(try $0.toData()) }
        return _todata_countable_case(value: data, count: count, header: .array)
    }
}

extension Array: CacheDecodable where Element: CacheDecodable {
    public static func initialize(fromCache data: Data) throws -> (instance: Array<Element>, restData: Data) {
        let process = _initialize_countable_case(data, header: .array)
        var data = process.data
        var array = [Element]()
        for _ in 0..<process.count {
            let rt = try Element.initialize(fromCache: data)
            array.append(rt.instance)
            data = rt.restData
        }
        return (array, data)
    }
}

extension Dictionary: CacheEncodable where Key: CacheEncodable, Value: CacheEncodable {
    public func toData() throws -> Data {
        var data = Data()
        try forEach {
            data.append(try $0.key.toData())
            data.append(try $0.value.toData())
        }
        return _todata_countable_case(value: data, count: count, header: .dictionay)
    }
}

extension Dictionary: CacheDecodable where Key: CacheDecodable, Value: CacheDecodable {
    public static func initialize(fromCache data: Data) throws -> (instance: Dictionary<Key, Value>, restData: Data) {
        let process = _initialize_countable_case(data, header: .dictionay)
        var data = process.data
        var dictionay = [Key: Value]()
        for _ in 0..<process.count {
            let k = try Key.initialize(fromCache: data)
            let v = try Value.initialize(fromCache: k.restData)
            dictionay[k.instance] = v.instance
            data = v.restData
        }
        return (dictionay, data)
    }
}
