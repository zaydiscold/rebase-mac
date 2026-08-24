import Foundation
import SwiftUI

@Observable
final class AppState {
    var selectedLane: Lane = .ideas
    var draft: String = ""
    var days: [PrototypeDay]
    var visibleRect: CGRect = .zero
    var dayFrames: [String: CGRect] = [:]
    var collapsedMonths: Set<String> = []

    init() {
        let calendar = PrototypeData.makeCalendar()
        if let saved = NotesStore.loadDays() {
            let byId = Dictionary(uniqueKeysWithValues: saved.map { ($0.id, $0) })
            days = calendar.map { byId[$0.id] ?? $0 }
        } else {
            days = calendar
        }
        ensureToday()
        collapsedMonths = Set(
            monthSections.filter(\.startsCollapsed).map(\.id)
        )
    }

    var monthSections: [MonthSection] {
        var sections: [MonthSection] = []
        var bucket: [PrototypeDay] = []
        var currentKey: String?
        var currentTitle: String?
        func flush() {
            guard let key = currentKey, let title = currentTitle, !bucket.isEmpty else { return }
            let sample = bucket[0]
            sections.append(
                MonthSection(
                    id: key,
                    title: title,
                    days: bucket,
                    startsCollapsed: Self.monthIsAutoCollapsed(year: sample.year, month: sample.month)
                )
            )
            bucket = []
        }
        for day in days {
            if currentKey != day.monthKey {
                flush()
                currentKey = day.monthKey
                currentTitle = day.monthTitle
            }
            bucket.append(day)
        }
        flush()
        return sections
    }

    func isMonthExpanded(_ id: String) -> Bool {
        !collapsedMonths.contains(id)
    }

    func toggleMonth(_ id: String) {
        if collapsedMonths.contains(id) {
            collapsedMonths.remove(id)
        } else {
            collapsedMonths.insert(id)
        }
    }

    private static func monthIsAutoCollapsed(year: Int, month: Int) -> Bool {
        let cal = PrototypeData.calendar
        let now = Date()
        let nowIndex = cal.component(.year, from: now) * 12 + cal.component(.month, from: now)
        let thenIndex = year * 12 + month
        return nowIndex - thenIndex >= 3
    }

    func capture() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        ensureToday()
        let entry = PrototypeEntry(
            id: UUID().uuidString,
            body: text,
            isTask: selectedLane != .ideas
        )
        var today = days[0]
        today.insert(entry, into: selectedLane)
        days[0] = today
        draft = ""
        save()
    }

    func toggleDone(dayId: String, lane: Lane, entryId: String) {
        guard let index = days.firstIndex(where: { $0.id == dayId }) else { return }
        var day = days[index]
        day.toggle(entryId, in: lane)
        days[index] = day
        save()
    }

    func toggleImportant(dayId: String, lane: Lane, entryId: String) {
        guard let index = days.firstIndex(where: { $0.id == dayId }) else { return }
        var day = days[index]
        day.toggleImportant(entryId, in: lane)
        days[index] = day
        save()
    }

    func ensureToday() {
        let today = PrototypeData.todayId()
        if days.first?.id == today { return }
        if let existing = days.firstIndex(where: { $0.id == today }) {
            let day = days.remove(at: existing)
            days.insert(day, at: 0)
            return
        }
        days.insert(
            PrototypeDay.empty(from: Date(), calendar: PrototypeData.calendar),
            at: 0
        )
    }

    func counts(relativeTo visible: CGRect, below: Bool) -> [Lane: Int] {
        var ideas = 0
        var life = 0
        var work = 0
        for day in days {
            guard let frame = dayFrames[day.id] else { continue }
            let isBelow = frame.minY > visible.maxY - 4
            let isAbove = frame.maxY < visible.minY + 4
            let matches = below ? isBelow : isAbove
            guard matches else { continue }
            ideas += day.ideas.count
            life += day.life.filter { !$0.done }.count
            work += day.work.filter { !$0.done }.count
        }
        return [.ideas: ideas, .life: life, .work: work]
    }

    private func save() {
        NotesStore.saveDays(days)
    }
}
