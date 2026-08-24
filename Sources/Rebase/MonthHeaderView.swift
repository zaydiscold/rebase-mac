import SwiftUI

struct MonthSection: Identifiable {
    let id: String
    let title: String
    var days: [PrototypeDay]
}

struct MonthHeaderView: View {
    let section: MonthSection
    let expanded: Bool
    var onToggle: () -> Void
    @Environment(\.palette) private var palette
    @Environment(\.accent) private var accent

    private var openCount: Int {
        section.days.reduce(into: 0) { total, day in
            for lane in Lane.allCases {
                total += day.entries(in: lane).filter { !$0.done }.count
            }
        }
    }

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 8) {
                Image(systemName: expanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(palette.muted)
                    .frame(width: 12)
                Text(section.title.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.4)
                    .foregroundStyle(palette.ink)
                Rectangle().fill(accent.color.opacity(0.34)).frame(height: 1)
                if !expanded {
                    Text(openCount == 1 ? "1 open" : "\(openCount) open")
                        .font(Theme.stampFont)
                        .monospacedDigit()
                        .foregroundStyle(palette.muted)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(palette.paper)
        .help(expanded ? "Collapse \(section.title)" : "Expand \(section.title)")
    }
}
