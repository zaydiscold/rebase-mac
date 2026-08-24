import Foundation
import XCTest
@testable import Rebase

final class TimelineDisclosureStoreTests: XCTestCase {
    private var suiteName = ""
    private var defaults: UserDefaults!
    private var store: TimelineDisclosureStore!

    override func setUp() {
        super.setUp()
        suiteName = "RebaseTests.TimelineDisclosure.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        store = TimelineDisclosureStore(defaults: defaults, key: "snapshot")
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        store = nil
        defaults = nil
        super.tearDown()
    }

    func testDisclosureSnapshotRoundTrips() throws {
        let snapshot = TimelineDisclosureSnapshot(
            collapsedDays: ["2026-08-23"],
            collapsedMonths: ["2026-07"],
            knownDays: ["2026-08-23", "2026-08-24"],
            knownMonths: ["2026-07", "2026-08"]
        )

        store.save(snapshot)

        XCTAssertEqual(try XCTUnwrap(store.load()), snapshot)
    }

    func testMissingSnapshotReturnsNil() {
        XCTAssertNil(store.load())
    }

    func testCorruptSnapshotReturnsNil() {
        defaults.set(Data("not-json".utf8), forKey: "snapshot")
        XCTAssertNil(store.load())
    }
}
