import Foundation

struct PrototypeEntry: Identifiable, Hashable {
    let id: String
    let body: String
    let isTask: Bool
    var done: Bool = false
}

struct PrototypeDay: Identifiable {
    let id: String
    let month: Int
    let day: Int
    let year: Int
    let weekday: String
    let ideas: [PrototypeEntry]
    let life: [PrototypeEntry]
    let work: [PrototypeEntry]

    var stamp: String { "\(month) · \(day) · \(year % 100)" }
    var fullDate: String { "\(weekday), August \(day), 20\(year % 100)" }

    func entries(in lane: Lane) -> [PrototypeEntry] {
        switch lane {
        case .ideas: ideas
        case .life: life
        case .work: work
        }
    }
}

enum PrototypeData {
    static let olderOpen: [Lane: Int] = [
        .ideas: 184,
        .life: 26,
        .work: 41,
    ]

    static let days: [PrototypeDay] = [
        PrototypeDay(
            id: "2026-08-23",
            month: 8, day: 23, year: 2026,
            weekday: "Sunday",
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
            life: [
                t("Submit last month's gym claim"),
                t("Call dentist"),
            ],
            work: [
                t("Prep meeting notes"),
            ]
        ),
        PrototypeDay(
            id: "2026-08-22",
            month: 8, day: 22, year: 2026,
            weekday: "Saturday",
            ideas: [
                e("Crowd control is a date line, not a folder tree"),
                e("Three lanes. Permanent. No fourth."),
            ],
            life: [
                t("Pay the electric bill"),
                t("Text mom"),
                t("Buy coffee beans"),
                t("Schedule oil change"),
            ],
            work: [
                t("Review the rollout notes"),
                t("Send the Friday status"),
            ]
        ),
        PrototypeDay(
            id: "2026-08-21",
            month: 8, day: 21, year: 2026,
            weekday: "Friday",
            ideas: [
                e("A day overflowing with ideas and barely occupied by work should visibly look that way. The empty paper is the point, not a layout bug."),
            ],
            life: [
                t("Pick up dry cleaning"),
            ],
            work: []
        ),
        PrototypeDay(
            id: "2026-08-20",
            month: 8, day: 20, year: 2026,
            weekday: "Thursday",
            ideas: [
                e("Keep the giant Notes dump out of the app until JSONL import exists"),
            ],
            life: [
                t("Renew the license plate"),
            ],
            work: [
                t("Read the design review thread"),
                t("Close the leftover ticket from Tuesday"),
            ]
        ),
    ]

    private static func e(_ body: String) -> PrototypeEntry {
        PrototypeEntry(id: UUID().uuidString, body: body, isTask: false)
    }

    private static func t(_ body: String) -> PrototypeEntry {
        PrototypeEntry(id: UUID().uuidString, body: body, isTask: true)
    }
}
