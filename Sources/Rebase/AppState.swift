import Foundation
import SwiftUI

@Observable
final class AppState {
    var selectedLane: Lane = .ideas
    var draft: String = ""
    var draftImportant = false
    var days: [PrototypeDay]
    var visibleRect: CGRect = .zero
    var dayFrames: [String: CGRect] = [:]
    var collapsedMonths: Set<String> = []
    var collapsedDays: Set<String> = []

    private let disclosureStore: TimelineDisclosureStore

    init(disclosureStore: TimelineDisclosureStore = TimelineDisclosureStore()) {
        self.disclosureStore = disclosureStore

        let recentDays = PrototypeData.makeCalendar()
        if let saved = NotesStore.loadDays() {
            days = Self.merge(savedDays: saved, recentDays: recentDays)
        } else {
            days = recentDays
        }
        ensureToday()
        restoreDisclosureState()
    }

    /// Combines the generated recent calendar with every durable saved day.
    /// Saved content wins over an empty generated placeholder for the same ID.
    /// Iterating into a dictionary also makes duplicate saved IDs deterministic
    /// instead of trapping in `Dictionary(uniqueKeysWithValues:)`.
    static func merge(savedDays: [PrototypeDay], recentDays: [PrototypeDay]) -> [PrototypeDay] {
        var byId: [String: PrototypeDay] = [:]

        for day in savedDays {
            byId[day.id] = day
        }
        for day in recentDays where byId[day.id] == nil {
            byId[day.id] = day
        }

        return byId.values.sorted { $0.id > $1.id }
    }

    var currentMonthKey: String {
        let cal = PrototypeData.calendar
        let now = Date()
        return String(format: "%04d-%02d", cal.component(.year, from: now), cal.component(.month, from: now))
    }

    var monthSections: [MonthSection] {
        var sections: [MonthSection] = []
        for day in days {
            if sections.last?.id != day.monthKey {
                sections.append(MonthSection(id: day.monthKey, title: day.monthTitle, days: [day]))
            } else {
                sections[sections.count - 1].days.append(day)
            }
        }
        return sections
    }

    func isMonthExpanded(_ id: String) -> Bool { !collapsedMonths.contains(id) }
    func isDayExpanded(_ id: String) -> Bool { !collapsedDays.contains(id) }

    func toggleMonth(_ id: String) {
        collapsedMonths.formSymmetricDifference([id])
        persistDisclosureState()
    }

    func toggleDay(_ id: String) {
        collapsedDays.formSymmetricDifference([id])
        persistDisclosureState()
    }

    private static func monthIsAutoCollapsed(_ key: String) -> Bool {
        let parts = key.split(separator: "-")
        guard parts.count == 2, let year = Int(parts[0]), let month = Int(parts[1]) else { return false }
        let cal = PrototypeData.calendar
        let now = Date()
        let nowIndex = cal.component(.year, from: now) * 12 + cal.component(.month, from: now)
        return nowIndex - (year * 12 + month) >= 3
    }

    func capture() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        ensureToday()
        days[0].insert(
            PrototypeEntry(
                id: UUID().uuidString,
                body: text,
                important: draftImportant
            ),
            into: selectedLane
        )
        collapsedDays.remove(days[0].id)
        draft = ""
        draftImportant = false
        persistDisclosureState()
        save()
    }

    func toggleDone(dayId: String, lane: Lane, entryId: String) {
        mutate(dayId: dayId, lane: lane, entryId: entryId) { $0.done.toggle() }
    }

    func toggleImportant(dayId: String, lane: Lane, entryId: String) {
        mutate(dayId: dayId, lane: lane, entryId: entryId) { $0.important.toggle() }
    }

    func editEntry(dayId: String, lane: Lane, entryId: String, body: String) {
        let text = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        mutate(dayId: dayId, lane: lane, entryId: entryId) { $0.body = text }
    }

    func applyMarkdown(_ imported: [PrototypeDay]) {
        for incoming in imported {
            if let i = days.firstIndex(where: { $0.id == incoming.id }) {
                days[i].ideas = incoming.ideas
                days[i].life = incoming.life
                days[i].work = incoming.work
            } else {
                days.append(incoming)
            }
            if !incoming.isEmpty {
                collapsedDays.remove(incoming.id)
            }
        }
        days.sort { $0.id > $1.id }
        ensureToday()
        persistDisclosureState()
        save()
    }

    func ensureToday() {
        let today = PrototypeData.todayId()
        if days.first?.id == today { return }
        if let existing = days.firstIndex(where: { $0.id == today }) {
            days.insert(days.remove(at: existing), at: 0)
            return
        }
        days.insert(PrototypeDay.empty(from: Date(), calendar: PrototypeData.calendar), at: 0)
    }

    func olderCounts(in visible: CGRect) -> [Lane: Int] {
        var ideas = 0, life = 0, work = 0
        for day in days {
            guard let frame = dayFrames[day.id], frame.minY > visible.maxY - 4 else { continue }
            ideas += day.ideas.filter { !$0.done }.count
            life += day.life.filter { !$0.done }.count
            work += day.work.filter { !$0.done }.count
        }
        return [.ideas: ideas, .life: life, .work: work]
    }

    private func restoreDisclosureState() {
        let dayIds = Set(days.map(\.id))
        let monthIds = Set(monthSections.map(\.id))

        if let saved = disclosureStore.load() {
            collapsedDays = saved.collapsedDays.intersection(dayIds)
            collapsedMonths = saved.collapsedMonths.intersection(monthIds)

            for day in days where !saved.knownDays.contains(day.id) && day.isEmpty {
                collapsedDays.insert(day.id)
            }
            for month in monthSections
                where !saved.knownMonths.contains(month.id) && Self.monthIsAutoCollapsed(month.id) {
                collapsedMonths.insert(month.id)
            }
        } else {
            // Empty dates are compact by default. Expanding one is an explicit
            // choice and will be remembered on the next launch.
            collapsedDays = Set(days.filter(\.isEmpty).map(\.id))
            collapsedMonths = Set(
                monthSections
                    .filter { Self.monthIsAutoCollapsed($0.id) }
                    .map(\.id)
            )
        }

        persistDisclosureState()
    }

    private func persistDisclosureState() {
        disclosureStore.save(
            TimelineDisclosureSnapshot(
                collapsedDays: collapsedDays,
                collapsedMonths: collapsedMonths,
                knownDays: Set(days.map(\.id)),
                knownMonths: Set(monthSections.map(\.id))
            )
        )
    }

    private func mutate(dayId: String, lane: Lane, entryId: String, _ update: (inout PrototypeEntry) -> Void) {
        guard let index = days.firstIndex(where: { $0.id == dayId }) else { return }
        days[index].map(entryId, in: lane, update)
        save()
    }

    private func save() { NotesStore.saveDays(days) }
}
