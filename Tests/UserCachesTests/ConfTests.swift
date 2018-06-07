//
//  ConfTests.swift
//  UserCachesTests
//
//  Created by He,Junqiu on 2018/6/7.
//

import XCTest
@testable import UserCaches
#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

class ConfTests: XCTestCase {
    func testConfRead() {
        let conf_file = "/tmp/usercaches_config"
        XCTAssertEqual(confRead(forKey: "cache_filepath", configFilepath: conf_file), "/home/xh/test.cache.db")
    }
    static var allTests = [
        ("testConfRead", testConfRead),
    ]
}
