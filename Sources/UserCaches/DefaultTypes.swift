//
//  DefaultTypes.swift
//  UserCaches
//
//  Created by hejunqiu on 2018/6/3.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import Foundation

public enum TypeHeader: UInt32 {
    case unknown    = 0b0000_0000_0000_0000_0000_0000_0000_0000
    case bool       = 0b1000_0000_0000_0000_0000_0000_0000_0000
    case int        = 0b1000_1000_0000_0000_0000_0000_0000_0000
    case int64      = 0b1001_0000_0000_0000_0000_0000_0000_0000
    case uint       = 0b1001_1000_0000_0000_0000_0000_0000_0000
    case uint64     = 0b1010_0000_0000_0000_0000_0000_0000_0000
    case float      = 0b1010_1000_0000_0000_0000_0000_0000_0000
    case double     = 0b1011_0000_0000_0000_0000_0000_0000_0000
    case string     = 0b1011_1000_0000_0000_0000_0000_0000_0000
    case data       = 0b1100_0000_0000_0000_0000_0000_0000_0000
    case date       = 0b1100_1000_0000_0000_0000_0000_0000_0000
    case array      = 0b1101_0000_0000_0000_0000_0000_0000_0000
    case dictionary = 0b1101_1000_0000_0000_0000_0000_0000_0000
    case codable    = 0b1110_0000_0000_0000_0000_0000_0000_0000
}

extension Data {
    @inline(__always)
    func subrangeToEnd(withOffset offset: Int) -> Data {
        return self[self.startIndex.advanced(by: offset)...]
    }
}

@inline(__always)
func throwByCondition(_ condition: @autoclosure () -> Bool, _ exception: @autoclosure () -> Error) throws {
    if condition() == false {
        throw exception()
    }
}

@inline(__always)
private func _initialize<T: Numeric>(fromCache data: Data, header: TypeHeader) throws -> (instance: T, restData: Data) {
    try throwByCondition(data.count >= MemoryLayout<UInt32>.size + MemoryLayout<T>.size,
                         DecodingError.invalidLength(header, DecodingError.Context(debugDescription: "Excepted length is \(MemoryLayout.size(ofValue: header.rawValue) + MemoryLayout<Int>.size), but storage is \(data.count)", underlyingError: nil)))

    let k = data.withUnsafeBytes { (uint32_ptr: UnsafePointer<UInt32>) in return uint32_ptr.pointee }
    try throwByCondition(k == header.rawValue,
                         DecodingError.typeMisMatch(header, DecodingError.Context(debugDescription: "Expected \(header), but storage is \(TypeHeader(rawValue: k) ?? .unknown)", underlyingError: nil)))

    let data = data.subrangeToEnd(withOffset: MemoryLayout<UInt32>.size)
    let v = data.withUnsafeBytes { (T_ptr: UnsafePointer<T>) in return T_ptr.pointee }
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
    public static func initialize(fromCache data: Data) throws -> (instance: Bool, restData: Data) {
        try throwByCondition(data.count >= MemoryLayout<UInt32>.size, DecodingError.invalidLength(.bool, DecodingError.Context(debugDescription: "Excepted length is \(MemoryLayout<UInt32>.size)), but storage is \(data.count)", underlyingError: nil)))

        let v = data.withUnsafeBytes { (uint32_ptr: UnsafePointer<UInt32>) in return uint32_ptr.pointee }
        try throwByCondition(v & TypeHeader.bool.rawValue == TypeHeader.bool.rawValue, DecodingError.invalidValue(.bool, DecodingError.Context(debugDescription: "Error: the indicated data(\(v)) is not a boolean value.", underlyingError: nil)))
        return (data[data.startIndex] == 1, data.subrangeToEnd(withOffset: MemoryLayout.size(ofValue: v)))
    }

    public func toData() -> Data {
        var v = (self ? 1 : 0) | TypeHeader.bool.rawValue
        let data = Data(bytes: &v, count: MemoryLayout<UInt32>.size)
        return data
    }
}

extension Int: CacheCodable {
    public static func initialize(fromCache data: Data) throws -> (instance: Int, restData: Data) {
        return try _initialize(fromCache: data, header: .int)
    }

    public func toData() -> Data {
        return _toData(value: self, header: .int)
    }
}

extension Int64: CacheCodable {
    public static func initialize(fromCache data: Data) throws -> (instance: Int64, restData: Data) {
        return try _initialize(fromCache: data, header: .int)
    }

    public func toData() -> Data {
        return _toData(value: self, header: .int)
    }
}

extension UInt: CacheCodable {
    public static func initialize(fromCache data: Data) throws -> (instance: UInt, restData: Data) {
        return try _initialize(fromCache: data, header: .uint)
    }

    public func toData() -> Data {
        return _toData(value: self, header: .uint)
    }
}

extension UInt64: CacheCodable {
    public static func initialize(fromCache data: Data) throws -> (instance: UInt64, restData: Data) {
        return try _initialize(fromCache: data, header: .uint)
    }

    public func toData() -> Data {
        return _toData(value: self, header: .uint)
    }
}

extension Float: CacheCodable {
    public static func initialize(fromCache data: Data) throws -> (instance: Float, restData: Data) {
        return try _initialize(fromCache: data, header: .float)
    }

    public func toData() -> Data {
        return _toData(value: self, header: .float)
    }
}

extension Double: CacheCodable {
    public static func initialize(fromCache data: Data) throws -> (instance: Double, restData: Data) {
        return try _initialize(fromCache: data, header: .double)
    }

    public func toData() -> Data {
        return _toData(value: self, header: .double)
    }
}

extension Date: CacheCodable {
    public static func initialize(fromCache data: Data) throws -> (instance: Date, restData: Data) {
        let process: (instance: TimeInterval, restData: Data) = try _initialize(fromCache: data, header: .date)
        return (Date(timeIntervalSince1970: process.instance), process.restData)
    }

    public func toData() -> Data {
        return _toData(value: timeIntervalSince1970, header: .date)
    }
}

@inline(__always)
func _initialize_countable_case(_ data: Data, header: TypeHeader) throws -> (data: Data, count: Int) {
    try throwByCondition(data.count >= MemoryLayout.size(ofValue: header.rawValue) + MemoryLayout<Int>.size,
                         DecodingError.invalidLength(header, .init(debugDescription: "Excepted length is \(MemoryLayout.size(ofValue: header.rawValue) + MemoryLayout<Int>.size), but storage is \(data.count)",     underlyingError: nil)))

    let k = data.withUnsafeBytes { (uint32_ptr: UnsafePointer<UInt32>) in return uint32_ptr.pointee }
    try throwByCondition(k == header.rawValue,
                         DecodingError.typeMisMatch(header, DecodingError.Context(debugDescription: "Expected \(header), but storage is \(TypeHeader(rawValue: k) ?? .unknown)", underlyingError: nil)))

    var data = data.subrangeToEnd(withOffset: MemoryLayout<UInt32>.size)
    let cnt = data.withUnsafeBytes { (int_ptr: UnsafePointer<Int>) in return int_ptr.pointee }
    data = data.subrangeToEnd(withOffset: MemoryLayout<Int>.size)
    return (data, cnt)
}

@inline(__always)
func _todata_countable_case(value: Data, count: Int, header: TypeHeader) -> Data {
    var k = header.rawValue
    let header = Data(bytes: &k, count: MemoryLayout.size(ofValue: k))
    var count = count
    let countField = Data(bytes: &count, count: MemoryLayout.size(ofValue: count))
    return header + countField + value
}

extension String: CacheCodable {
    public static func initialize(fromCache data: Data) throws -> (instance: String, restData: Data) {
        let data = try _initialize_countable_case(data, header: .string)
        guard let v = String(data: data.data[..<data.data.startIndex.advanced(by: data.count)], encoding: .utf8) else {
            throw DecodingError.typeMisMatch(.string, DecodingError.Context(debugDescription: "Error: can't decode a String from Data(\(data))", underlyingError: nil))
        }
        return (v, data.data.subrangeToEnd(withOffset: data.count))
    }

    public func toData() throws -> Data {
        guard let data = self.data(using: .utf8) else {
            throw EncodingError.invalidValue(.string, EncodingError.Context(debugDescription: "Error: can't encode String('\(self)')", underlyingError: nil))
        }
        return _todata_countable_case(value: data, count: data.count, header: .string)
    }
}

extension Data: CacheCodable {
    public static func initialize(fromCache data: Data) throws -> (instance: Data, restData: Data) {
        let process = try _initialize_countable_case(data, header: .data)
        let (data, count) = (process.data, process.count)
        return (data[..<data.startIndex.advanced(by: count)], data.subrangeToEnd(withOffset: count))
    }

    public func toData() -> Data {
        return _todata_countable_case(value: self, count: count, header: .data)
    }
}

extension Array: CacheEncodable where Element: CacheEncodable {
    public func toData() throws -> Data {
        do {
            var data = Data()
            try forEach { data.append(try $0.toData()) }
            return _todata_countable_case(value: data, count: count, header: .array)
        } catch {
            throw EncodingError.invalidValue(.array, EncodingError.Context(debugDescription: "Error: can't encode Element(\(Element.self))", underlyingError: error))
        }
    }
}

extension Array: CacheDecodable where Element: CacheDecodable {
    public static func initialize(fromCache data: Data) throws -> (instance: Array<Element>, restData: Data) {
        let process = try _initialize_countable_case(data, header: .array)
        var data = process.data
        var array = [Element]()
        do {
            for _ in 0..<process.count {
                let rt = try Element.initialize(fromCache: data)
                array.append(rt.instance)
                data = rt.restData
            }
        } catch {
            throw DecodingError.containterIncomplete(.array, DecodingError.Context(debugDescription: "Error: can't decode Array", underlyingError: error))
        }

        return (array, data)
    }
}

extension Dictionary: CacheEncodable where Key: CacheEncodable, Value: CacheEncodable {
    public func toData() throws -> Data {
        var sentry = false
        do {
            var data = Data()
            try forEach {
                sentry = false
                data.append(try $0.key.toData())
                sentry = true
                data.append(try $0.value.toData())
            }
            return _todata_countable_case(value: data, count: count, header: .dictionary)
        } catch {
            let desc = sentry ? "Error: can't encode Key(\(Key.self))" : "Error: can't encode Value(\(Value.self))"
            throw EncodingError.invalidValue(.dictionary, EncodingError.Context(debugDescription: desc, underlyingError: error))
        }
    }
}

extension Dictionary: CacheDecodable where Key: CacheDecodable, Value: CacheDecodable {
    public static func initialize(fromCache data: Data) throws -> (instance: Dictionary<Key, Value>, restData: Data) {
        let process = try _initialize_countable_case(data, header: .dictionary)
        var data = process.data
        var dictionay = [Key: Value]()
        var sentry = false
        do {
            for _ in 0..<process.count {
                sentry = false
                let k = try Key.initialize(fromCache: data)
                sentry = true
                let v = try Value.initialize(fromCache: k.restData)
                dictionay[k.instance] = v.instance
                data = v.restData
            }
        } catch {
            let desc = sentry ? "Error: can't decode Key(\(Key.self))" : "Error: can't decode Value(\(Value.self))"
            throw DecodingError.containterIncomplete(.dictionary, DecodingError.Context(debugDescription: desc, underlyingError: error))
        }
        return (dictionay, data)
    }
}
