import XCTest
@testable import KeychainOTPKit

final class KeychainOTPKitTests: XCTestCase {
    func testExample() {
        let keychainOTPKit = KeychainOTPKit(with: KeychainCore(keychainService: "keychainService"))
        XCTAssertNotNil(keychainOTPKit)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
