import Foundation

struct RebaseMarkdownParseError: LocalizedError, Equatable {
    let line: Int
    let reason: String

    var errorDescription: String? {
        "Line \(line): \(reason)"
    }
}

enum RebaseMarkdown {
    static func render(_ days: [PrototypeDay]) -> String {
        var out = "# rebase\n\nTo-do list triage.\n\n"
        for day in days where !day.isEmpty {
            out += "## \(day.id)\n\n"
            for lane in Lane.allCases {
                out += "### \(lane.title)\n"
                for entry in day.entries(in: lane) {
                    out += line(entry) + "\n"
                }
                out += "\n"
            }
        }
        return out
    }

    static func parse(_ text: String) throws -> [PrototypeDay] {
        var days: [String: PrototypeDay] = [:]
        var order: [String] = []
        var currentId: String?
        var currentLane: Lane = .ideas

        for (offset, raw) in text.components(separatedBy: .newlines).enumerated() {
            let lineNumber = offset + 1
            let line = raw.trimmingCharacters(in: .whitespaces)
            let lowercased = line.lowercased()

            if line.isEmpty || lowercased.hasPrefix("# rebase") || line == "To-do list triage." {
                continue
            }

            if line.hasPrefix("## ") {
                let id = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                guard let parsed = PrototypeDay.parse(id: id), parsed.id == id else {
                    throw RebaseMarkdownParseError(
                        line: lineNumber,
                        reason: "Invalid date heading '\(id)'. Expected YYYY-MM-DD."
                    )
                }

                currentId = id
                currentLane = .ideas
                if days[id] == nil {
                    order.append(id)
                    days[id] = parsed
                }
                continue
            }

            if line.hasPrefix("### ") {
                guard currentId != nil else {
                    throw RebaseMarkdownParseError(
                        line: lineNumber,
                        reason: "Lane heading appears before a valid day heading."
                    )
                }

                let name = String(line.dropFirst(4)).trimmingCharacters(in: .whitespaces)
                guard let lane = Lane.allCases.first(where: {
                    $0.title.caseInsensitiveCompare(name) == .orderedSame
                }) else {
                    throw RebaseMarkdownParseError(
                        line: lineNumber,
                        reason: "Unknown lane '\(name)'. Expected Ideas, Life, or Work."
                    )
                }
                currentLane = lane
                continue
            }

            if line.hasPrefix("- ") {
                guard let id = currentId, var working = days[id] else {
                    throw RebaseMarkdownParseError(
                        line: lineNumber,
                        reason: "Entry appears before a valid day heading."
                    )
                }

                let bodyLine = String(line.dropFirst(2))
                working.append(try entry(from: bodyLine, lineNumber: lineNumber), into: currentLane)
                days[id] = working
            }
        }

        return order.compactMap { days[$0] }
    }

    private static func line(_ entry: PrototypeEntry) -> String {
        let star = entry.important ? "* " : ""
        return "- [\(entry.done ? "x" : " ")] \(star)\(escapeBody(entry.body))"
    }

    private static func entry(from raw: String, lineNumber: Int) throws -> PrototypeEntry {
        var rest = raw
        let done: Bool

        if rest.lowercased().hasPrefix("[x]") {
            done = true
            rest = String(rest.dropFirst(3)).trimmingCharacters(in: .whitespaces)
        } else if rest.hasPrefix("[ ]") {
            done = false
            rest = String(rest.dropFirst(3)).trimmingCharacters(in: .whitespaces)
        } else {
            throw RebaseMarkdownParseError(
                line: lineNumber,
                reason: "Entry must begin with [ ] or [x]."
            )
        }

        var important = false
        if rest.hasPrefix("* ") {
            important = true
            rest = String(rest.dropFirst(2))
        }

        return PrototypeEntry(
            id: UUID().uuidString,
            body: unescapeBody(rest),
            done: done,
            important: important
        )
    }

    private static func escapeBody(_ body: String) -> String {
        if body.hasPrefix("* ") || body.hasPrefix("\\") {
            return "\\" + body
        }
        return body
    }

    private static func unescapeBody(_ body: String) -> String {
        if body.hasPrefix("\\* ") || body.hasPrefix("\\\\") {
            return String(body.dropFirst())
        }
        return body
    }
}
