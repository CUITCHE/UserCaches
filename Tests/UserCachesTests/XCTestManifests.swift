import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(UserCachesTests.allTests),
        testCase(ConfTests.allTests),
    ]
}
#endif
