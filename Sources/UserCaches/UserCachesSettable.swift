//
//  UserCachesSettable.swift
//  UserCaches
//
//  Created by He,Junqiu on 2018/6/5.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import Foundation

public enum CacheKeyMode {
    /// Keep raw type string.
    case raw
    /// Only change the type name. For example:
    ///
    ///     enum ComOrganizationProductCaches: String, UserCachesSettable {
    ///         case some
    ///     }
    ///
    /// When use ComOrganizationProductCaches.some, change it to **com.organization.product.caches.some**
    case identifyType
    /// Only change the case name, replaced "_" with ".". For example:
    ///
    ///     enum ComOrganizationProductCaches: String, UserCachesSettable {
    ///         case some_1
    ///     }
    ///
    /// When use ComOrganizationProductCaches.some_1, change it to ComOrganizationProductCaches.some.1
    case identifyCase
    /// Effective equal to identifyType & identifyCase. For example:
    ///
    ///     enum ComOrganizationProductCaches: String, UserCachesSettable {
    ///         case some_1
    ///     }
    ///
    /// When use ComOrganizationProductCaches.some_1, change it to com.organization.product.caches.some.1
    case identifier
}

public protocol UserCachesSettable {
    /// Generate a String combined 'type' and 'rawValue' with '.'.
    var key: String { get }

    /// Indicate the key style. Default is CacheKeyMode.raw. See: *CacheKeyMode*
    var identifierMode: CacheKeyMode { get }
}

public extension UserCachesSettable where Self: RawRepresentable, Self.RawValue == String {
    /// Store cache to a global instance of UserCaches(standard).
    ///
    /// The stored value must defer to CacheEncodable. UserCaches framework has builtin some type defered it:
    ///
    /// [**Bool**, **Int**, **Int64** **UInt**, **UInt64** **Float**, **Double**, **String**, **Data**, **Date**, **Array<CacheEncodable>**, **Dictionary<CacheEncodable, CacheEncodable>**], **Codable**.
    ///
    /// Also use the type defer to **Codable**. Wrap Codable by **CacheCodability** (CacheCodability(value: Codable)).
    public var storage: CacheEncodable {
        nonmutating set {
            do {
                try UserCaches.standard.set(newValue, forKey: key)
            } catch {
                print(error)
            }
        }
        get { assertionFailure("The storage.getter is abandon. And it always return 0 at product environment."); return 0 }
    }

    /// Get cache from a global instance of UserCaches(standard).
    ///
    /// - Returns: A value deferred to CacheDecodable.
    public func value<T: CacheDecodable>() -> T? {
        do {
            return try UserCaches.standard.value(forKey: key)
        } catch {
            print(error)
        }
        return nil
    }

    /// Get cache from a global instance of UserCaches(standard).
    ///
    /// - Returns: A value deferred to Decodable.
    public func valueofCodable<T: Decodable>() -> T? {
        do {
            let v: CacheCodability<T> = try UserCaches.standard.value(forKey: key)
            return v.value
        } catch {
            print(error)
        }
        return nil
    }

    public var key: String {
        var type = "\(Self.self)"
        var `case` = rawValue

        func identifyType() {
            type = type.reduce(into: "") { (result, ch) in
                guard ch.unicodeScalars.first!.isASCII == true else { result += String(ch); return }
                let value = UInt8(ch.unicodeScalars.first!.value)
                let isUpper = _asciiUpperCaseTable &>> UInt64(((value &- 1) & 0b0111_1111) &>> 1)
                let add = (isUpper & 0x1) &<< 5
                ((isUpper & 0x1) != 0 && result.isEmpty == false) ? result += "." : ()
                result += String(Character(Unicode.Scalar(value &+ UInt8(truncatingIfNeeded: add))))
            }
        }

        func identifyCase() {
            `case` = `case`.replacingOccurrences(of: "_", with: ".")
        }

        switch identifierMode {
        case .raw: break
        case .identifyType:
            identifyType()
        case .identifyCase:
            identifyCase()
        case .identifier:
            identifyType()
            identifyCase()
        }
        return [type, `case`].joined(separator: ".")
    }

    public var identifierMode: CacheKeyMode { return .raw }

    private var _asciiUpperCaseTable: UInt64 { @inline(__always) get { return 0b0000_0000_0000_0000_0001_1111_1111_1111_0000_0000_0000_0000_0000_0000_0000_0000 } }
}
