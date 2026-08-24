import Foundation

struct PrototypeEntry: Identifiable, Codable {
    let id: String
    let body: String
    var done: Bool
    var important: Bool

    init(id: String, body: String, done: Bool = false, important: Bool = false) {
        self.id = id
        self.body = body
        self.done = done
        self.important = important
    }
}

struct PrototypeDay: Identifiable, Codable {
    let id: String
    let month: Int
    let day: Int
    let year: Int
    let weekday: String
    var ideas: [PrototypeEntry]
    var life: [PrototypeEntry]
    var work: [PrototypeEntry]

    var stamp: String { "\(month) · \(day) · \(year % 100)" }

    var fullDate: String {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        comps.timeZone = TimeZone(identifier: "America/Los_Angeles")
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = comps.timeZone ?? .current
        guard let date = cal.date(from: comps) else { return stamp }
        return date.formatted(.dateTime.weekday(.wide).month(.wide).day().year().locale(Locale(identifier: "en_US")))
    }

    func entries(in lane: Lane) -> [PrototypeEntry] {
        switch lane {
        case .ideas: ideas
        case .life: life
        case .work: work
        }
    }

    mutating func insert(_ entry: PrototypeEntry, into lane: Lane) {
        switch lane {
        case .ideas: ideas.insert(entry, at: 0)
        case .life: life.insert(entry, at: 0)
        case .work: work.insert(entry, at: 0)
        }
    }

    mutating func append(_ entry: PrototypeEntry, into lane: Lane) {
        switch lane {
        case .ideas: ideas.append(entry)
        case .life: life.append(entry)
        case .work: work.append(entry)
        }
    }

    mutating func map(_ id: String, in lane: Lane, _ update: (inout PrototypeEntry) -> Void) {
        switch lane {
        case .ideas:
            if let i = ideas.firstIndex(where: { $0.id == id }) { update(&ideas[i]) }
        case .life:
            if let i = life.firstIndex(where: { $0.id == id }) { update(&life[i]) }
        case .work:
            if let i = work.firstIndex(where: { $0.id == id }) { update(&work[i]) }
        }
    }

    var monthKey: String { String(format: "%04d-%02d", year, month) }

    var monthTitle: String {
        let names = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        let name = (month >= 1 && month <= 12) ? names[month] : "Month"
        return "\(name) \(year)"
    }

    var isEmpty: Bool { ideas.isEmpty && life.isEmpty && work.isEmpty }

    static func parse(id: String) -> PrototypeDay? {
        let parts = id.split(separator: "-")
        guard parts.count == 3,
              let y = Int(parts[0]), let m = Int(parts[1]), let d = Int(parts[2]) else {
            return nil
        }
        var comps = DateComponents()
        comps.year = y
        comps.month = m
        comps.day = d
        comps.timeZone = TimeZone(identifier: "America/Los_Angeles")
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = comps.timeZone ?? .current
        guard let date = cal.date(from: comps) else { return nil }
        return empty(from: date, calendar: cal)
    }

    static func empty(from date: Date, calendar: Calendar) -> PrototypeDay {
        let parts = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
        let y = parts.year ?? 0
        let m = parts.month ?? 0
        let d = parts.day ?? 0
        let weekdayNames = ["", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let weekday = weekdayNames[parts.weekday ?? 0]
        return PrototypeDay(
            id: String(format: "%04d-%02d-%02d", y, m, d),
            month: m, day: d, year: y, weekday: weekday,
            ideas: [], life: [], work: []
        )
    }
}

enum PrototypeData {
    static var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        return cal
    }

    static func todayId(now: Date = Date()) -> String {
        let p = calendar.dateComponents([.year, .month, .day], from: now)
        return String(format: "%04d-%02d-%02d", p.year ?? 0, p.month ?? 0, p.day ?? 0)
    }

    static func makeCalendar(back: Int = 120, now: Date = Date()) -> [PrototypeDay] {
        let seeded = Dictionary(uniqueKeysWithValues: sampleDays.map { ($0.id, $0) })
        return (0..<back).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: now) else { return nil }
            let empty = PrototypeDay.empty(from: date, calendar: calendar)
            return seeded[empty.id] ?? empty
        }
    }

    static let sampleDays: [PrototypeDay] = [
        PrototypeDay(
            id: "2026-08-23", month: 8, day: 23, year: 2026, weekday: "Sunday",
            ideas: [
                e("A notepad that refuses to become a second job"),
                e("Maxims belong in a lane that never grows a checkbox"),
                e("Blank space on a day is a success metric"),
                e("The past can exist without sitting in today's working memory"),
                e("Capture is two decisions: the words, then Ideas / Life / Work"),
                e("A protein design tool that tells a mutation as a biological story"),
                e("Do not auto-carry unfinished tasks into tomorrow. That is how a list becomes an accusation"),
                e("Rebase moves. It never copies."),
            ],
            life: [t("Submit last month's gym claim"), t("Call dentist")],
            work: [t("Prep meeting notes")]
        ),
        PrototypeDay(
            id: "2026-08-22", month: 8, day: 22, year: 2026, weekday: "Saturday",
            ideas: [
                e("Crowd control is a date line, not a folder tree"),
                e("Three lanes. Permanent. No fourth."),
            ],
            life: [t("Pay the electric bill"), t("Text mom"), t("Buy coffee beans"), t("Schedule oil change")],
            work: [t("Review the rollout notes"), t("Send the Friday status")]
        ),
        PrototypeDay(
            id: "2026-08-21", month: 8, day: 21, year: 2026, weekday: "Friday",
            ideas: [e("A day overflowing with ideas and barely occupied by work should visibly look that way. The empty paper is the point, not a layout bug.")],
            life: [t("Pick up dry cleaning")],
            work: []
        ),
        PrototypeDay(
            id: "2026-08-20", month: 8, day: 20, year: 2026, weekday: "Thursday",
            ideas: [e("Keep the giant Notes dump out of the app until JSONL import exists")],
            life: [t("Renew the license plate")],
            work: [t("Read the design review thread"), t("Close the leftover ticket from Tuesday")]
        ),
    ]

    private static func e(_ body: String) -> PrototypeEntry {
        PrototypeEntry(id: UUID().uuidString, body: body)
    }

    private static func t(_ body: String) -> PrototypeEntry {
        PrototypeEntry(id: UUID().uuidString, body: body)
    }
}
