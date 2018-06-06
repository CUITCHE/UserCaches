//
//  CodingError.swift
//  UserCaches
//
//  Created by He,Junqiu on 2018/6/6.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import Foundation

public enum EncodingError: Error {
    public struct Context {
        /// A description of what went wrong, for debugging purposes.
        public let debugDescription: String

        /// The underlying error which caused this error, if any.
        public let underlyingError: Error?
    }
    case invalidValue(TypeHeader, Context)
}

public enum DecodingError: Error {
    public struct Context {
        /// A description of what went wrong, for debugging purposes.
        public let debugDescription: String

        /// The underlying error which caused this error, if any.
        public let underlyingError: Error?
    }
    case invalidLength(TypeHeader, Context)
    case typeMisMatch(TypeHeader, Context)
    case containterIncomplete(TypeHeader, Context)
    case invalidValue(TypeHeader, Context)
}
