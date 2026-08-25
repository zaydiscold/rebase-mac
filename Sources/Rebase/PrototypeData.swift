import Foundation

struct PrototypeEntry: Identifiable, Codable {
    let id: String
    var body: String
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

        let weekdayNames = ["", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let monthNames = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        let weekdayIndex = cal.component(.weekday, from: date)
        let monthIndex = cal.component(.month, from: date)
        let dayValue = cal.component(.day, from: date)
        let yearValue = cal.component(.year, from: date)

        guard weekdayNames.indices.contains(weekdayIndex),
              monthNames.indices.contains(monthIndex) else {
            return stamp
        }

        return "\(weekdayNames[weekdayIndex]), \(monthNames[monthIndex]) \(Self.ordinalDay(dayValue)), \(yearValue)"
    }

    static func ordinalDay(_ value: Int) -> String {
        let remainder100 = value % 100
        let suffix: String

        if (11...13).contains(remainder100) {
            suffix = "th"
        } else {
            switch value % 10 {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
        }

        return "\(value)\(suffix)"
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
        (0..<back).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: now).map {
                PrototypeDay.empty(from: $0, calendar: calendar)
            }
        }
    }

}
