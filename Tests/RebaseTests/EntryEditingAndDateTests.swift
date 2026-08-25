import XCTest
@testable import Rebase

final class EntryEditingAndDateTests: XCTestCase {
    func testEditingBodyPreservesEntryIdentityAndFlags() throws {
        var day = try XCTUnwrap(PrototypeDay.parse(id: "2026-08-23"))
        day.life = [
            PrototypeEntry(
                id: "entry-1",
                body: "Original task",
                done: true,
                important: true
            ),
        ]

        day.map("entry-1", in: .life) { entry in
            entry.body = "Edited task"
        }

        let edited = try XCTUnwrap(day.life.first)
        XCTAssertEqual(edited.id, "entry-1")
        XCTAssertEqual(edited.body, "Edited task")
        XCTAssertTrue(edited.done)
        XCTAssertTrue(edited.important)
    }

    func testExpandedDateUsesFullOrdinalHierarchy() throws {
        let day = try XCTUnwrap(PrototypeDay.parse(id: "2026-08-23"))

        XCTAssertEqual(day.stamp, "8 · 23 · 26")
        XCTAssertEqual(day.fullDate, "Sunday, August 23rd, 2026")
    }

    func testOrdinalSuffixesHandleTeensAndDecades() {
        XCTAssertEqual(PrototypeDay.ordinalDay(1), "1st")
        XCTAssertEqual(PrototypeDay.ordinalDay(2), "2nd")
        XCTAssertEqual(PrototypeDay.ordinalDay(3), "3rd")
        XCTAssertEqual(PrototypeDay.ordinalDay(4), "4th")
        XCTAssertEqual(PrototypeDay.ordinalDay(11), "11th")
        XCTAssertEqual(PrototypeDay.ordinalDay(12), "12th")
        XCTAssertEqual(PrototypeDay.ordinalDay(13), "13th")
        XCTAssertEqual(PrototypeDay.ordinalDay(21), "21st")
        XCTAssertEqual(PrototypeDay.ordinalDay(22), "22nd")
        XCTAssertEqual(PrototypeDay.ordinalDay(23), "23rd")
        XCTAssertEqual(PrototypeDay.ordinalDay(31), "31st")
    }
}
