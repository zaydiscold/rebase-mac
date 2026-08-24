import Foundation

enum RebaseMarkdown {
    static func render(_ days: [PrototypeDay]) -> String {
        var out = "# rebase\n\nTo-do list triage.\n\n"
        for day in days where !day.isEmpty {
            out += "## \(day.id)\n\n"
            for lane in Lane.allCases {
                out += "### \(lane.title)\n"
                for entry in day.entries(in: lane) {
                    out += line(entry, lane: lane) + "\n"
                }
                out += "\n"
            }
        }
        return out
    }

    static func parse(_ text: String) -> [PrototypeDay] {
        var days: [String: PrototypeDay] = [:]
        var order: [String] = []
        var currentId: String?
        var currentLane: Lane = .ideas

        func day(_ id: String) -> PrototypeDay {
            if let existing = days[id] { return existing }
            order.append(id)
            let created = PrototypeDay.parse(id: id) ?? PrototypeDay.empty(from: Date(), calendar: PrototypeData.calendar)
            days[id] = created
            return created
        }

        for raw in text.components(separatedBy: .newlines) {
            let line = raw.trimmingCharacters(in: .whitespaces)
            if line.isEmpty || line.hasPrefix("# rebase") || line == "To-do list triage." { continue }
            if line.hasPrefix("## ") {
                let id = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                currentId = id
                _ = day(id)
                continue
            }
            if line.hasPrefix("### ") {
                let name = String(line.dropFirst(4)).lowercased()
                currentLane = Lane.allCases.first { $0.title.lowercased() == name } ?? .ideas
                continue
            }
            guard line.hasPrefix("- "), let id = currentId else { continue }
            let bodyLine = String(line.dropFirst(2))
            var working = days[id] ?? day(id)
            working.append(entry(from: bodyLine, lane: currentLane), into: currentLane)
            days[id] = working
        }

        return order.compactMap { days[$0] }
    }

    private static func line(_ entry: PrototypeEntry, lane: Lane) -> String {
        let star = entry.important ? "* " : ""
        return "- [\(entry.done ? "x" : " ")] \(star)\(entry.body)"
    }

    private static func entry(from raw: String, lane: Lane) -> PrototypeEntry {
        var rest = raw
        var done = false
        if rest.lowercased().hasPrefix("[x]") {
            done = true
            rest = String(rest.dropFirst(3)).trimmingCharacters(in: .whitespaces)
        } else if rest.hasPrefix("[ ]") {
            rest = String(rest.dropFirst(3)).trimmingCharacters(in: .whitespaces)
        }
        var important = false
        if rest.hasPrefix("* ") {
            important = true
            rest = String(rest.dropFirst(2))
        }
        return PrototypeEntry(
            id: UUID().uuidString,
            body: rest,
            done: done,
            important: important
        )
    }
}
