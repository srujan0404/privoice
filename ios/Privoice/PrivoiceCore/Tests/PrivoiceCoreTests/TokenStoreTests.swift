import XCTest
@testable import PrivoiceCore

final class TokenStoreTests: XCTestCase {
    // Use a test-only service identifier so we don't clobber real tokens.
    // Also skip the App Group access group — tests don't run inside a signed container.
    private let sut = TokenStore(service: "com.privoice.tokens.test", accessGroup: nil)

    override func setUp() {
        super.setUp()
        sut.clear()
    }

    override func tearDown() {
        sut.clear()
        super.tearDown()
    }

    func test_loadReturnsNil_whenNothingStored() {
        XCTAssertNil(sut.load())
    }

    func test_saveAndLoad_roundTrips() throws {
        let tokens = TokenStore.Tokens(access: "a-token", refresh: "r-token")
        try sut.save(tokens)
        XCTAssertEqual(sut.load(), tokens)
    }

    func test_save_overwritesExistingTokens() throws {
        try sut.save(.init(access: "a1", refresh: "r1"))
        try sut.save(.init(access: "a2", refresh: "r2"))
        XCTAssertEqual(sut.load(), .init(access: "a2", refresh: "r2"))
    }

    func test_updateAccess_replacesAccessOnly() throws {
        try sut.save(.init(access: "a1", refresh: "r1"))
        try sut.updateAccess("a2")
        XCTAssertEqual(sut.load(), .init(access: "a2", refresh: "r1"))
    }

    func test_clear_removesBoth() throws {
        try sut.save(.init(access: "a1", refresh: "r1"))
        sut.clear()
        XCTAssertNil(sut.load())
    }
}
