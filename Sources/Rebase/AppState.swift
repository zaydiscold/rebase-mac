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

    init() {
        let recentDays = PrototypeData.makeCalendar()
        if let saved = NotesStore.loadDays() {
            days = Self.merge(savedDays: saved, recentDays: recentDays)
        } else {
            days = recentDays
        }
        ensureToday()
        collapsedMonths = Set(monthSections.filter { Self.monthIsAutoCollapsed($0.id) }.map(\.id))
        let today = PrototypeData.todayId()
        collapsedDays = Set(days.filter { $0.isEmpty && $0.id != today }.map(\.id))
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
    func toggleMonth(_ id: String) { collapsedMonths.formSymmetricDifference([id]) }
    func toggleDay(_ id: String) { collapsedDays.formSymmetricDifference([id]) }

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
        save()
    }

    func toggleDone(dayId: String, lane: Lane, entryId: String) {
        mutate(dayId: dayId, lane: lane, entryId: entryId) { $0.done.toggle() }
    }

    func toggleImportant(dayId: String, lane: Lane, entryId: String) {
        mutate(dayId: dayId, lane: lane, entryId: entryId) { $0.important.toggle() }
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
        }
        days.sort { $0.id > $1.id }
        ensureToday()
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

    private func mutate(dayId: String, lane: Lane, entryId: String, _ update: (inout PrototypeEntry) -> Void) {
        guard let index = days.firstIndex(where: { $0.id == dayId }) else { return }
        days[index].map(entryId, in: lane, update)
        save()
    }

    private func save() { NotesStore.saveDays(days) }
}
