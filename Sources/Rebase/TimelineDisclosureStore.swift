import Foundation

struct TimelineDisclosureSnapshot: Codable, Equatable {
    var collapsedDays: Set<String>
    var collapsedMonths: Set<String>
    var knownDays: Set<String>
    var knownMonths: Set<String>
}

struct TimelineDisclosureStore {
    private let defaults: UserDefaults
    private let key: String

    init(
        defaults: UserDefaults = .standard,
        key: String = "rebase.timeline-disclosure.v1"
    ) {
        self.defaults = defaults
        self.key = key
    }

    func load() -> TimelineDisclosureSnapshot? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(TimelineDisclosureSnapshot.self, from: data)
    }

    func save(_ snapshot: TimelineDisclosureSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: key)
    }
}
