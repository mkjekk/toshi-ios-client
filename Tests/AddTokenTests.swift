import XCTest
import UIKit
import Teapot
@testable import Toshi

class AddTokenTests: XCTestCase {

    func testAddToken() {

        let mockTeapot = MockTeapot(bundle: Bundle(for: IDAPIClientTests.self), mockFilename: "")
        mockTeapot.overrideEndPoint("timestamp", withFilename: "timestamp")
        let ethereumAPIClient = EthereumAPIClient(mockTeapot: mockTeapot)

        let expectation = XCTestExpectation(description: "adds a custom token")

        let address = "0x4d8fc1453a0f359e99c9675954e656d80d996fbf"
        ethereumAPIClient.addToken(with: address) { success, error in
            XCTAssertTrue(success)
            expectation.fulfill()

         }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
