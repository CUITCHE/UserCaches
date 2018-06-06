import XCTest
@testable import UserCaches
#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

enum ComOrganizationProductCaches: String, UserCachesSettable {
    case boolean, int, int_negative, uint, float, double, string, data, date, codable
    case array_boolean, array_int, array_float, array_double, array_date, array_codable
    case dict_boolean, dict_int, dict_com_1, dict_com_2, dict_com_3, dict_com_4, dict_codable

    var identifierMode: CacheKeyMode { return .identifier }
}

var once = true

final class UserCachesTests: XCTestCase {
    override func setUp() {
        super.setUp()
        if once {
            print(UserCaches.standard.db.db)
            once = false
        }
    }

    func testSingleSaveCache() {
        ComOrganizationProductCaches.boolean.storage = true
        XCTAssertEqual(ComOrganizationProductCaches.boolean.value(), true)

        ComOrganizationProductCaches.int.storage = 13503
        XCTAssertEqual(ComOrganizationProductCaches.int.value(), 13503)

        ComOrganizationProductCaches.int_negative.storage = -113503
        XCTAssertEqual(ComOrganizationProductCaches.int_negative.value(), -113503)

        ComOrganizationProductCaches.uint.storage = 0xC0020840020C4011 as UInt
        XCTAssertEqual(ComOrganizationProductCaches.uint.value(), 0xC0020840020C4011 as UInt)

        ComOrganizationProductCaches.float.storage = Float(73.43)
        XCTAssertEqual(ComOrganizationProductCaches.float.value(), Float(73.43))

        ComOrganizationProductCaches.double.storage = 73.43
        XCTAssertEqual(ComOrganizationProductCaches.double.value(), 73.43)

        ComOrganizationProductCaches.string.storage = "This is String 😊"
        XCTAssertEqual(ComOrganizationProductCaches.string.value(), "This is String 😊")

        let str = "Data data ✔️"
        let data = str.data(using: .utf8)!
        ComOrganizationProductCaches.data.storage = data
        XCTAssertEqual(ComOrganizationProductCaches.data.value(), data)

        let date = Date()
        ComOrganizationProductCaches.date.storage = date
        let date1: Date? = ComOrganizationProductCaches.date.value()
        XCTAssertEqual(date1?.timeIntervalSince1970, date.timeIntervalSince1970)

        let app = App(users: [User(name: "Li Hua", age: 18, score: 550),
                              User(name: "Han Meimei", age: 19, score: 690)],
                      attribute: ["Li Hua": "TianDao", "Han Meimei": "Loving"])
        ComOrganizationProductCaches.codable.storage = CacheCodability(value: app)
        XCTAssertEqual(ComOrganizationProductCaches.codable.valueofCodable(), app)
    }

    func testArraySaveCache() {
        var array0 = [Bool]()
        var b = true
        for idx in 0..<100 {
            array0.append(b)
            b = idx % 7 == 0 ? b : !b
        }
        ComOrganizationProductCaches.array_boolean.storage = array0
        XCTAssertEqual(ComOrganizationProductCaches.array_boolean.value(), array0)

        var array1 = [Int]()
        for idx in 0..<10000 {
            array1.append(idx)
        }
        ComOrganizationProductCaches.array_int.storage = array1
        XCTAssertEqual(ComOrganizationProductCaches.array_int.value(), array1)

        func _random(lower: Int, upper: Int) -> Double {
            #if os(Linux)
            let m1 = Double(random() % 1000001) / Double(1000001)
            let m2 = Double(Int(random()) % (upper - lower) + lower)
            #else
            let m1 = Double(arc4random() % 1000001) / Double(1000001)
            let m2 = Double(Int(arc4random()) % (upper - lower) + lower)
            #endif
            return m2 + m1

        }
        var array2 = [Float]()
        for _ in 0..<1000 {
            array2.append(Float(_random(lower: 10, upper: 99999999)))
        }
        ComOrganizationProductCaches.array_float.storage = array2
        XCTAssertEqual(ComOrganizationProductCaches.array_float.value(), array2)

        var array3 = [Double]()
        for _ in 0..<1000 {
            array3.append(_random(lower: 10, upper: 99999999))
        }
        ComOrganizationProductCaches.array_double.storage = array3
        XCTAssertEqual(ComOrganizationProductCaches.array_double.value(), array3)

        var array4 = [Date]()
        for _ in 0..<1000 {
            array4.append(Date())
            Thread.sleep(forTimeInterval: 0.001)
        }
        ComOrganizationProductCaches.array_date.storage = array4
        let array4_: [Date]? = ComOrganizationProductCaches.array_date.value()
        XCTAssertEqual(array4.count, array4_?.count)
        for (d1, d2) in zip(array4, array4_!) {
            XCTAssertEqual(d1.timeIntervalSince1970, d2.timeIntervalSince1970)
        }

        var array5 = [CacheCodability<User>]()
        for _ in 0..<1000 {
            array5.append(CacheCodability(value: .demo))
        }
        ComOrganizationProductCaches.array_codable.storage = array5
        XCTAssertEqual(ComOrganizationProductCaches.array_codable.value(), array5)
    }

    func testDictionaySaveCache() {
        // simple combination
        let dict0 = [true: false, false: true]
        ComOrganizationProductCaches.dict_boolean.storage = dict0
        XCTAssertEqual(ComOrganizationProductCaches.dict_boolean.value(), dict0)

        let dict1 = [1: 3, 543563: 54756, 315: 756865]
        ComOrganizationProductCaches.dict_int.storage = dict1
        XCTAssertEqual(ComOrganizationProductCaches.dict_int.value(), dict1)

        let dict2 = ["kk": 255, "kkkk": 32]
        ComOrganizationProductCaches.dict_com_1.storage = dict2
        XCTAssertEqual(ComOrganizationProductCaches.dict_com_1.value(), dict2)

        // value is array
        let dict3 = ["k1": [1,2,3,4], "k2": [45,6575,74]]
        ComOrganizationProductCaches.dict_com_2.storage = dict3
        XCTAssertEqual(ComOrganizationProductCaches.dict_com_2.value(), dict3)

        let dict4 = ["423534": ["fref454", "54353", "fewfver"], "fcret453": ["53453", "54353", "543523423dew", "54352342"]]
        ComOrganizationProductCaches.dict_com_3.storage = dict4
        XCTAssertEqual(ComOrganizationProductCaches.dict_com_3.value(), dict4)

        // value is dictionay
        let dict5: [Int: [String: [String]]] = [1: ["423534": ["fref454", "54353", "fewfver"]],
                                                2: ["fcret453": ["53453", "54353", "543523423dew", "54352342"]]
        ]
        ComOrganizationProductCaches.dict_com_4.storage = dict5
        XCTAssertEqual(ComOrganizationProductCaches.dict_com_4.value(), dict5)

        let dict6: [String: CacheCodability<User>] = ["abc": CacheCodability(value: User.demo),
                                                      "xxxxx": CacheCodability(value: User.demo)]
        ComOrganizationProductCaches.dict_codable.storage = dict6
        XCTAssertEqual(ComOrganizationProductCaches.dict_codable.value(), dict6)
    }

    func testKeyGeneratePerformance() {
        enum ComOrganizationProductCachesCADsweERF32RFW5FEFG$gtfew2y7DGTHYCDWE: String, UserCachesSettable {
            case some
            var identifierModel: CacheKeyMode { return .identifier }
        }
        measure {
            for _ in 0..<100 {
                _ = ComOrganizationProductCachesCADsweERF32RFW5FEFG$gtfew2y7DGTHYCDWE.some.key
            }
        }
        print(ComOrganizationProductCachesCADsweERF32RFW5FEFG$gtfew2y7DGTHYCDWE.some.key, ComOrganizationProductCaches.data.key)
    }
    static var allTests = [
        ("testSingleSaveCache", testSingleSaveCache),
        ("testArraySaveCache", testArraySaveCache),
        ("testDictionaySaveCache", testDictionaySaveCache),
        ("testKeyGeneratePerformance", testKeyGeneratePerformance)
    ]
}
