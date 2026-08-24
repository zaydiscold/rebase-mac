import XCTest
@testable import Rebase

final class AppSettingsNormalizationTests: XCTestCase {
    func testOvercommittedEqualSharesPreserveEqualPreference() {
        let normalized = AppSettings.normalizedColumnShares(ideas: 0.50, life: 0.50)

        XCTAssertEqual(normalized.ideas, 0.42, accuracy: 0.000_001)
        XCTAssertEqual(normalized.life, 0.42, accuracy: 0.000_001)
        XCTAssertEqual(normalized.ideas + normalized.life, 0.84, accuracy: 0.000_001)
    }

    func testValidSharesRemainUnchanged() {
        let normalized = AppSettings.normalizedColumnShares(ideas: 0.37, life: 0.37)

        XCTAssertEqual(normalized.ideas, 0.37, accuracy: 0.000_001)
        XCTAssertEqual(normalized.life, 0.37, accuracy: 0.000_001)
    }

    func testSharesClampToMinimumLaneWidths() {
        let normalized = AppSettings.normalizedColumnShares(ideas: 0.01, life: -4)

        XCTAssertEqual(normalized.ideas, 0.18, accuracy: 0.000_001)
        XCTAssertEqual(normalized.life, 0.18, accuracy: 0.000_001)
    }

    func testNonFiniteSharesFallBackToFiniteDefaults() {
        let normalized = AppSettings.normalizedColumnShares(ideas: .nan, life: .infinity)

        XCTAssertTrue(normalized.ideas.isFinite)
        XCTAssertTrue(normalized.life.isFinite)
        XCTAssertGreaterThanOrEqual(normalized.ideas, 0.18)
        XCTAssertGreaterThanOrEqual(normalized.life, 0.18)
        XCTAssertLessThanOrEqual(normalized.ideas + normalized.life, 0.84 + 0.000_001)
    }

    func testUnequalOvercommitPreservesRelativePreference() {
        let normalized = AppSettings.normalizedColumnShares(ideas: 0.66, life: 0.30)

        XCTAssertGreaterThan(normalized.ideas, normalized.life)
        XCTAssertGreaterThanOrEqual(normalized.ideas, 0.18)
        XCTAssertGreaterThanOrEqual(normalized.life, 0.18)
        XCTAssertEqual(normalized.ideas + normalized.life, 0.84, accuracy: 0.000_001)
    }

    func testBodySizeNormalization() {
        XCTAssertEqual(AppSettings.normalizedBodySize(nil), 16)
        XCTAssertEqual(AppSettings.normalizedBodySize(.nan), 16)
        XCTAssertEqual(AppSettings.normalizedBodySize(.infinity), 16)
        XCTAssertEqual(AppSettings.normalizedBodySize(4), 13)
        XCTAssertEqual(AppSettings.normalizedBodySize(99), 22)
        XCTAssertEqual(AppSettings.normalizedBodySize(18), 18)
    }
}
