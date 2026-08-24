import XCTest
@testable import Rebase

final class UpdateCheckerTests: XCTestCase {
    private let releaseURL = URL(string: "https://github.com/zaydiscold/rebase-mac/releases/tag/v0.2.0")!
    private let commitURL = URL(string: "https://github.com/zaydiscold/rebase-mac/commit/abcdef1234567890")!

    func testSemanticVersionHandlesTagsAndMissingComponents() throws {
        XCTAssertEqual(try XCTUnwrap(SemanticVersion("v1.2.3")), SemanticVersion("1.2.3"))
        XCTAssertEqual(try XCTUnwrap(SemanticVersion("1.2")), SemanticVersion("1.2.0"))
        XCTAssertLessThan(try XCTUnwrap(SemanticVersion("0.9.9")), try XCTUnwrap(SemanticVersion("1.0.0")))
        XCTAssertLessThan(try XCTUnwrap(SemanticVersion("1.2.3")), try XCTUnwrap(SemanticVersion("1.2.4")))
        XCTAssertNil(SemanticVersion("release-latest"))
    }

    func testNewerReleaseTakesPriorityOverUnreleasedSource() {
        let decision = UpdateEvaluator.evaluate(
            currentVersion: "0.1.0",
            currentCommit: "1234567",
            release: GitHubRelease(tagName: "v0.2.0", htmlURL: releaseURL),
            mainCommit: GitHubCommit(sha: "abcdef1234567890", htmlURL: commitURL)
        )

        XCTAssertEqual(
            decision,
            .releaseAvailable(version: "v0.2.0", url: releaseURL)
        )
    }

    func testChangedMainCommitReportsUnreleasedSource() {
        let decision = UpdateEvaluator.evaluate(
            currentVersion: "0.2.0",
            currentCommit: "1234567",
            release: GitHubRelease(tagName: "v0.2.0", htmlURL: releaseURL),
            mainCommit: GitHubCommit(sha: "abcdef1234567890", htmlURL: commitURL)
        )

        XCTAssertEqual(
            decision,
            .sourceAvailable(commit: "abcdef1234567890", url: commitURL)
        )
    }

    func testMatchingShortCommitIsCurrent() {
        let decision = UpdateEvaluator.evaluate(
            currentVersion: "0.2.0",
            currentCommit: "abcdef1",
            release: GitHubRelease(tagName: "v0.2.0", htmlURL: releaseURL),
            mainCommit: GitHubCommit(sha: "abcdef1234567890", htmlURL: commitURL)
        )

        XCTAssertEqual(decision, .current(latestVersion: "v0.2.0"))
    }

    func testNoPublishedReleaseIsExplicit() {
        let decision = UpdateEvaluator.evaluate(
            currentVersion: "0.1.0",
            currentCommit: "abcdef1",
            release: nil,
            mainCommit: GitHubCommit(sha: "abcdef1234567890", htmlURL: commitURL)
        )

        XCTAssertEqual(decision, .noPublishedRelease)
    }
}
