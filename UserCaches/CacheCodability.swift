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
    public func toData() throws -> Data {
        do {
            let data = try JSONEncoder().encode(value)
            return _todata_countable_case(value: data, count: data.count, header: .codable)
        } catch {
            throw EncodingError.invalidValue(.codable, EncodingError.Context(debugDescription: "Error: can't encode the Encodable type(\(T.self))", underlyingError: error))
        }
    }
}

extension CacheCodability: CacheDecodable where T: Decodable {
    public static func initialize(fromCache data: Data) throws -> (instance: CacheCodability<T>, restData: Data) {
        let process = try _initialize_countable_case(data, header: .codable)
        let (data, count) = (process.data, process.count)
        do {
            let v = try JSONDecoder().decode(T.self, from: data[..<data.startIndex.advanced(by: count)])
            return (CacheCodability(value: v), data[data.startIndex.advanced(by: count)...])
        } catch {
            throw DecodingError.containterIncomplete(.codable, DecodingError.Context(debugDescription: "Error: can't wrap \(T.self) to CacheCodability", underlyingError: error))
        }
    }
}

extension CacheCodability: Equatable where T: Equatable {
    public static func == (lhs: CacheCodability<T>, rhs: CacheCodability<T>) -> Bool {
        return lhs.value == rhs.value
    }
}
