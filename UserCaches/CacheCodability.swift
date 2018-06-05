//
//  CacheCodability.swift
//  UserCaches
//
//  Created by He,Junqiu on 2018/6/5.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import Foundation

public struct CacheCodability<T> {
    public let value: T
}

extension CacheCodability: CacheEncodable where T: Encodable {
    public func toData() -> Data {
        var k: UInt32 = TypeHeader.codable.rawValue
        let header = Data(bytes: &k, count: MemoryLayout.size(ofValue: k))
        let data = try! JSONEncoder().encode(value)
        var count = data.count
        let countField = Data(bytes: &count, count: MemoryLayout.size(ofValue: count))
        return header + countField + data
    }
}

extension CacheCodability: CacheDecodable where T: Decodable {
    public static func initialize(fromCache data: Data) -> (instance: CacheCodability<T>, restData: Data) {
        assert(data.count >= MemoryLayout<UInt32>.size + MemoryLayout<Int>.size)
        var k: UInt32 = 0
        (data as NSData).getBytes(&k, length: MemoryLayout<UInt32>.size)
        assert(k == TypeHeader.codable.rawValue)

        var count = 0
        var data = data.subrangeToEnd(withOffset: MemoryLayout<UInt32>.size)
        (data as NSData).getBytes(&count, length: MemoryLayout.size(ofValue: count))
        data = data.subrangeToEnd(withOffset: MemoryLayout.size(ofValue: count))

        let v = try! JSONDecoder().decode(T.self, from: data[..<data.startIndex.advanced(by: count)])
        return (CacheCodability(value: v), data[data.startIndex.advanced(by: count)...])
    }
}

extension CacheCodability: Equatable where T: Equatable {
    public static func == (lhs: CacheCodability<T>, rhs: CacheCodability<T>) -> Bool {
        return lhs.value == rhs.value
    }
}
