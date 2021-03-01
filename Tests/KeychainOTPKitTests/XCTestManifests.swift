import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    [
        testCase(KeychainOTPKitTests.allTests),
    ]
}
#endif
