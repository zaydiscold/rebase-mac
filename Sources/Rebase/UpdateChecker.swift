import AppKit
import Foundation
import Observation

struct SemanticVersion: Comparable, Equatable {
    let components: [Int]

    init?(_ rawValue: String) {
        var value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.first == "v" || value.first == "V" {
            value.removeFirst()
        }

        guard let core = value.split(whereSeparator: { $0 == "-" || $0 == "+" }).first else {
            return nil
        }

        let pieces = core.split(separator: ".", omittingEmptySubsequences: false)
        guard !pieces.isEmpty else { return nil }

        var parsed: [Int] = []
        for piece in pieces {
            guard let number = Int(piece), number >= 0 else { return nil }
            parsed.append(number)
        }

        while parsed.count < 3 {
            parsed.append(0)
        }
        components = parsed
    }

    static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        let count = max(lhs.components.count, rhs.components.count)
        for index in 0..<count {
            let left = index < lhs.components.count ? lhs.components[index] : 0
            let right = index < rhs.components.count ? rhs.components[index] : 0
            if left != right {
                return left < right
            }
        }
        return false
    }
}

struct GitHubRelease: Decodable, Equatable, Sendable {
    let tagName: String
    let htmlURL: URL

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case htmlURL = "html_url"
    }
}

struct GitHubCommit: Decodable, Equatable, Sendable {
    let sha: String
    let htmlURL: URL

    enum CodingKeys: String, CodingKey {
        case sha
        case htmlURL = "html_url"
    }
}

enum UpdateDecision: Equatable {
    case releaseAvailable(version: String, url: URL)
    case sourceAvailable(commit: String, url: URL)
    case current(latestVersion: String?)
    case noPublishedRelease
}

enum UpdateEvaluator {
    static func evaluate(
        currentVersion: String,
        currentCommit: String,
        release: GitHubRelease?,
        mainCommit: GitHubCommit
    ) -> UpdateDecision {
        if let release,
           let installed = SemanticVersion(currentVersion),
           let latest = SemanticVersion(release.tagName),
           installed < latest {
            return .releaseAvailable(version: release.tagName, url: release.htmlURL)
        }

        let installedCommit = currentCommit
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        let remoteCommit = mainCommit.sha.lowercased()
        let hasComparableCommit = !installedCommit.isEmpty && installedCommit != "unknown"
        let commitMatches = remoteCommit.hasPrefix(installedCommit) || installedCommit.hasPrefix(remoteCommit)

        if hasComparableCommit && !commitMatches {
            return .sourceAvailable(commit: mainCommit.sha, url: mainCommit.htmlURL)
        }

        if let release {
            return .current(latestVersion: release.tagName)
        }
        return .noPublishedRelease
    }
}

enum GitHubUpdateError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "GitHub returned an invalid response."
        case .httpStatus(let code):
            "GitHub returned HTTP \(code)."
        }
    }
}

enum GitHubUpdateService {
    private static let latestReleaseURL = URL(
        string: "https://api.github.com/repos/zaydiscold/rebase-mac/releases/latest"
    )!
    private static let mainCommitURL = URL(
        string: "https://api.github.com/repos/zaydiscold/rebase-mac/commits/main"
    )!

    static func fetchLatestRelease() async throws -> GitHubRelease? {
        let (data, response) = try await URLSession.shared.data(for: request(for: latestReleaseURL))
        guard let http = response as? HTTPURLResponse else {
            throw GitHubUpdateError.invalidResponse
        }
        if http.statusCode == 404 {
            return nil
        }
        guard (200..<300).contains(http.statusCode) else {
            throw GitHubUpdateError.httpStatus(http.statusCode)
        }
        return try JSONDecoder().decode(GitHubRelease.self, from: data)
    }

    static func fetchMainCommit() async throws -> GitHubCommit {
        let (data, response) = try await URLSession.shared.data(for: request(for: mainCommitURL))
        guard let http = response as? HTTPURLResponse else {
            throw GitHubUpdateError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw GitHubUpdateError.httpStatus(http.statusCode)
        }
        return try JSONDecoder().decode(GitHubCommit.self, from: data)
    }

    private static func request(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.timeoutInterval = 12
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        request.setValue("Rebase-macOS", forHTTPHeaderField: "User-Agent")
        return request
    }
}

@MainActor
@Observable
final class UpdateChecker {
    enum Status: Equatable {
        case idle
        case checking
        case current(latestVersion: String?)
        case releaseAvailable(version: String, url: URL)
        case sourceAvailable(commit: String, url: URL)
        case noPublishedRelease
        case failed(String)
    }

    private(set) var status: Status = .idle
    private(set) var lastCheckedAt: Date?
    private var automaticCheckStarted = false

    var currentVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
    }

    var currentCommit: String {
        Bundle.main.object(forInfoDictionaryKey: "GitCommit") as? String ?? "unknown"
    }

    var isChecking: Bool {
        status == .checking
    }

    var message: String {
        switch status {
        case .idle:
            "Not checked yet"
        case .checking:
            "Checking GitHub…"
        case .current(let latestVersion):
            if let latestVersion {
                "Current. Latest release is \(latestVersion)."
            } else {
                "This build is current."
            }
        case .releaseAvailable(let version, _):
            "Release \(version) is available."
        case .sourceAvailable(let commit, _):
            "New source is on main (\(String(commit.prefix(7))))."
        case .noPublishedRelease:
            "No published release yet."
        case .failed(let reason):
            "Could not check: \(reason)"
        }
    }

    var symbolName: String {
        switch status {
        case .idle:
            "arrow.triangle.2.circlepath"
        case .checking:
            "arrow.triangle.2.circlepath"
        case .current:
            "checkmark.circle"
        case .releaseAvailable:
            "arrow.down.circle"
        case .sourceAvailable:
            "hammer.circle"
        case .noPublishedRelease:
            "shippingbox"
        case .failed:
            "exclamationmark.triangle"
        }
    }

    var actionTitle: String? {
        switch status {
        case .releaseAvailable:
            "View release"
        case .sourceAvailable:
            "View changes"
        default:
            nil
        }
    }

    func checkAutomatically(enabled: Bool) async {
        guard enabled, !automaticCheckStarted else { return }
        automaticCheckStarted = true
        await check()
    }

    func check() async {
        guard status != .checking else { return }
        status = .checking

        do {
            async let releaseRequest = GitHubUpdateService.fetchLatestRelease()
            async let commitRequest = GitHubUpdateService.fetchMainCommit()
            let (release, mainCommit) = try await (releaseRequest, commitRequest)
            let decision = UpdateEvaluator.evaluate(
                currentVersion: currentVersion,
                currentCommit: currentCommit,
                release: release,
                mainCommit: mainCommit
            )
            apply(decision)
            lastCheckedAt = Date()
        } catch is CancellationError {
            status = .idle
        } catch {
            status = .failed(error.localizedDescription)
            lastCheckedAt = Date()
        }
    }

    func openAvailableUpdate() {
        let url: URL?
        switch status {
        case .releaseAvailable(_, let releaseURL):
            url = releaseURL
        case .sourceAvailable(_, let commitURL):
            url = commitURL
        default:
            url = nil
        }
        if let url {
            NSWorkspace.shared.open(url)
        }
    }

    private func apply(_ decision: UpdateDecision) {
        switch decision {
        case .releaseAvailable(let version, let url):
            status = .releaseAvailable(version: version, url: url)
        case .sourceAvailable(let commit, let url):
            status = .sourceAvailable(commit: commit, url: url)
        case .current(let latestVersion):
            status = .current(latestVersion: latestVersion)
        case .noPublishedRelease:
            status = .noPublishedRelease
        }
    }
}
