import XCTest
@testable import Rebase

final class AppStateMergeTests: XCTestCase {
    func testMergePreservesSavedDayOutsideRecentWindow() throws {
        let now = try makeDate(year: 2026, month: 8, day: 23)
        let recentDays = PrototypeData.makeCalendar(back: 120, now: now)
        let oldDate = try XCTUnwrap(
            PrototypeData.calendar.date(byAdding: .day, value: -121, to: now)
        )

        var oldDay = PrototypeDay.empty(from: oldDate, calendar: PrototypeData.calendar)
        oldDay.ideas = [
            PrototypeEntry(id: "old-entry", body: "Keep this history")
        ]

        let merged = AppState.merge(savedDays: [oldDay], recentDays: recentDays)

        XCTAssertEqual(merged.count, recentDays.count + 1)
        XCTAssertEqual(
            merged.first(where: { $0.id == oldDay.id })?.ideas.first?.body,
            "Keep this history"
        )
    }

    func testSavedContentWinsOverGeneratedPlaceholder() throws {
        let now = try makeDate(year: 2026, month: 8, day: 23)
        let recentDays = PrototypeData.makeCalendar(back: 5, now: now)
        var savedToday = try XCTUnwrap(recentDays.first)
        savedToday.life = [
            PrototypeEntry(id: "saved-entry", body: "Saved content")
        ]

        let merged = AppState.merge(savedDays: [savedToday], recentDays: recentDays)
        let today = try XCTUnwrap(merged.first(where: { $0.id == savedToday.id }))

        XCTAssertEqual(today.life.map(\.body), ["Saved content"])
    }

    func testDuplicateSavedIDsUseLastRecordWithoutCrashing() throws {
        let now = try makeDate(year: 2026, month: 8, day: 23)
        var first = PrototypeDay.empty(from: now, calendar: PrototypeData.calendar)
        first.work = [PrototypeEntry(id: "first", body: "First version")]

        var second = first
        second.work = [PrototypeEntry(id: "second", body: "Last version")]

        let merged = AppState.merge(savedDays: [first, second], recentDays: [])

        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(merged[0].work.map(\.body), ["Last version"])
    }

    func testMergedDaysRemainNewestFirst() throws {
        let now = try makeDate(year: 2026, month: 8, day: 23)
        let recentDays = PrototypeData.makeCalendar(back: 3, now: now)
        let olderDate = try XCTUnwrap(
            PrototypeData.calendar.date(byAdding: .day, value: -200, to: now)
        )
        let olderDay = PrototypeDay.empty(from: olderDate, calendar: PrototypeData.calendar)

        let merged = AppState.merge(savedDays: [olderDay], recentDays: recentDays)
        let ids = merged.map(\.id)

        XCTAssertEqual(ids, ids.sorted(by: >))
    }

    private func makeDate(year: Int, month: Int, day: Int) throws -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 12
        return try XCTUnwrap(PrototypeData.calendar.date(from: components))
    }
}
