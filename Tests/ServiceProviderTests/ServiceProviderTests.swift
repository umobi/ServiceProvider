import XCTest
import Combine
@testable import ServiceProvider

struct User: Codable {
    let name: String
}

final class ServiceProviderTests: XCTestCase {
    var cancellables: [AnyCancellable] = []

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
