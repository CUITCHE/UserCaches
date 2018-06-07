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
        let content = """
                    # The cache db file path. Must be absolute string.
                    # Create at executed directory by default. See UserCaches.standard.
                    #
                    cache_filepath=/home/xh/test.cache.db
                    # Support annotate. The below key-value will not be read.
                    # key=value
                    """
        do {
            try content.write(toFile: conf_file, atomically: true, encoding: .utf8)
        } catch {
            print(error)
        }
        defer {
            do {
                try FileManager.default.removeItem(atPath: conf_file)
            } catch {
                print(error)
            }
        }
        XCTAssertEqual(confRead(forKey: "cache_filepath", configFilepath: conf_file), "/home/xh/test.cache.db")
        XCTAssertEqual(confRead(forKey: "key", configFilepath: conf_file), nil)
    }

    func testConf() {
        let content = """
                    # The cache db file path. Must be absolute string.
                    # Create at executed directory by default. See UserCaches.standard.
                    #
                    cache_filepath=/home/xh/test.cache.db
                    """
        do {
            try content.write(toFile: configFilepath, atomically: true, encoding: .utf8)
        } catch {
            print(error)
        }
        defer {
            do {
                try FileManager.default.removeItem(atPath: configFilepath)
            } catch {
                print(error)
            }
        }
        XCTAssertEqual(Conf.cache_filepath.stringValue(), "/home/xh/test.cache.db")
    }
    static var allTests = [
        ("testConfRead", testConfRead),
    ]
}
