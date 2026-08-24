import XCTest
@testable import Rebase

final class RebaseMarkdownTests: XCTestCase {
    func testRoundTripPreservesReservedPrefixesAndEntryState() throws {
        var day = try XCTUnwrap(PrototypeDay.parse(id: "2026-08-23"))
        day.ideas = [
            PrototypeEntry(
                id: "normal-star",
                body: "* normal text",
                done: false,
                important: false
            ),
            PrototypeEntry(
                id: "important-star",
                body: "* important text",
                done: false,
                important: true
            ),
            PrototypeEntry(
                id: "leading-slash",
                body: "\\server path",
                done: true,
                important: false
            ),
        ]
        day.life = [
            PrototypeEntry(
                id: "life",
                body: "Call dentist",
                done: false,
                important: true
            ),
        ]
        day.work = [
            PrototypeEntry(
                id: "work",
                body: "Prepare review",
                done: true,
                important: false
            ),
        ]

        let rendered = RebaseMarkdown.render([day])
        let parsed = try RebaseMarkdown.parse(rendered)
        let roundTripped = try XCTUnwrap(parsed.first)

        XCTAssertEqual(roundTripped.id, "2026-08-23")
        XCTAssertEqual(roundTripped.ideas.map(\.body), ["* normal text", "* important text", "\\server path"])
        XCTAssertEqual(roundTripped.ideas.map(\.important), [false, true, false])
        XCTAssertEqual(roundTripped.ideas.map(\.done), [false, false, true])
        XCTAssertEqual(roundTripped.life.map(\.body), ["Call dentist"])
        XCTAssertEqual(roundTripped.life.map(\.important), [true])
        XCTAssertEqual(roundTripped.work.map(\.body), ["Prepare review"])
        XCTAssertEqual(roundTripped.work.map(\.done), [true])
    }

    func testInvalidDateDoesNotFallBackToToday() {
        let text = """
        # rebase

        ## 2026-02-31
        ### Ideas
        - [ ] Impossible date
        """

        XCTAssertThrowsError(try RebaseMarkdown.parse(text)) { error in
            guard let parseError = error as? RebaseMarkdownParseError else {
                return XCTFail("Unexpected error type: \(error)")
            }
            XCTAssertEqual(parseError.line, 3)
            XCTAssertTrue(parseError.reason.contains("Invalid date"))
        }
    }

    func testUnknownLaneFailsWithSourceLine() {
        let text = """
        # rebase
        ## 2026-08-23
        ### Maybe
        - [ ] Ambiguous
        """

        XCTAssertThrowsError(try RebaseMarkdown.parse(text)) { error in
            guard let parseError = error as? RebaseMarkdownParseError else {
                return XCTFail("Unexpected error type: \(error)")
            }
            XCTAssertEqual(parseError.line, 3)
            XCTAssertTrue(parseError.reason.contains("Unknown lane"))
        }
    }

    func testEntryBeforeDayFailsWithSourceLine() {
        let text = """
        # rebase
        - [ ] Orphan entry
        """

        XCTAssertThrowsError(try RebaseMarkdown.parse(text)) { error in
            guard let parseError = error as? RebaseMarkdownParseError else {
                return XCTFail("Unexpected error type: \(error)")
            }
            XCTAssertEqual(parseError.line, 2)
            XCTAssertTrue(parseError.reason.contains("before a valid day"))
        }
    }

    func testEntryBeforeLaneFailsInsteadOfDefaultingToIdeas() {
        let text = """
        # rebase
        ## 2026-08-23
        - [ ] Do not guess my lane
        """

        XCTAssertThrowsError(try RebaseMarkdown.parse(text)) { error in
            guard let parseError = error as? RebaseMarkdownParseError else {
                return XCTFail("Unexpected error type: \(error)")
            }
            XCTAssertEqual(parseError.line, 3)
            XCTAssertTrue(parseError.reason.contains("Ideas, Life, or Work"))
        }
    }

    func testMalformedCheckboxFailsInsteadOfBecomingBodyText() {
        let text = """
        # rebase
        ## 2026-08-23
        ### Ideas
        - [maybe] Not a checkbox
        """

        XCTAssertThrowsError(try RebaseMarkdown.parse(text)) { error in
            guard let parseError = error as? RebaseMarkdownParseError else {
                return XCTFail("Unexpected error type: \(error)")
            }
            XCTAssertEqual(parseError.line, 4)
            XCTAssertTrue(parseError.reason.contains("must begin"))
        }
    }

    func testUnrecognizedContentFailsInsteadOfDisappearing() {
        let text = """
        # rebase
        ## 2026-08-23
        ### Ideas
        This line must not disappear.
        """

        XCTAssertThrowsError(try RebaseMarkdown.parse(text)) { error in
            guard let parseError = error as? RebaseMarkdownParseError else {
                return XCTFail("Unexpected error type: \(error)")
            }
            XCTAssertEqual(parseError.line, 4)
            XCTAssertTrue(parseError.reason.contains("Unrecognized content"))
        }
    }

    func testDocumentHeadingMustBeExact() {
        let text = """
        # rebase notes that should not be ignored
        ## 2026-08-23
        ### Ideas
        - [ ] Entry
        """

        XCTAssertThrowsError(try RebaseMarkdown.parse(text)) { error in
            guard let parseError = error as? RebaseMarkdownParseError else {
                return XCTFail("Unexpected error type: \(error)")
            }
            XCTAssertEqual(parseError.line, 1)
            XCTAssertTrue(parseError.reason.contains("Unrecognized content"))
        }
    }
}
