import XCTest
@testable import PrivoiceCore

final class TonePreferenceTests: XCTestCase {
    private var defaults: UserDefaults!
    private var sut: TonePreference!
    private let suiteName = "com.privoice.tests.tone"

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        sut = TonePreference(userDefaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        sut = nil
        super.tearDown()
    }

    func test_returnsDefault_whenUnset() {
        XCTAssertEqual(sut.current, .casual)
    }

    func test_returnsDefault_whenValueIsGarbage() {
        defaults.set("not-a-tone", forKey: "selectedTone")
        XCTAssertEqual(sut.current, .casual)
    }

    func test_roundtripsEachCase() {
        for tone in Tone.allCases {
            sut.current = tone
            XCTAssertEqual(sut.current, tone)
        }
    }
}
