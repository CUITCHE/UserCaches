//
//  CacheCodable.swift
//  UserCaches
//
//  Created by hejunqiu on 2018/6/3.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import Foundation

/// A type that can encode itself to an binary data.
public protocol CacheEncodable {
    /// Encodes this value into binary data.
    ///
    /// - Returns: The data to write data to.
    /// - Throws:
    ///   - `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    ///   - An error if any value throws an error during encoding.
    func toData() throws -> Data
}

/// A type that can decode itself from an binary data.
public protocol CacheDecodable {
    /// Create a new instance by decoding from the given data and return rest data that has not been used.
    ///
    /// - Parameter data: The cache to read data from.
    /// - Returns: (new instance, rest data that has not been used)
    /// - Throws:
    ///   - `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid JSON.
    ///   - An error if any value throws an error during decoding.
    static func initialize(fromCache data: Data) throws -> (instance: Self, restData: Data)
}

public typealias CacheCodable = CacheEncodable & CacheDecodable
