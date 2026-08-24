import SwiftUI

struct EdgeIndicatorView: View {
    let below: [Lane: Int]
    @Environment(\.palette) private var palette
    @Environment(\.laneFractions) private var fractions

    var body: some View {
        LaneMaxHeightLayout(fractions: fractions) {
            chip(lane: .ideas, count: below[.ideas] ?? 0, noun: "older ideas")
            chip(lane: .life, count: below[.life] ?? 0, noun: "open")
            chip(lane: .work, count: below[.work] ?? 0, noun: "open")
        }
        .padding(.vertical, 4)
        .background(palette.paper)
    }

    private func chip(lane: Lane, count: Int, noun: String) -> some View {
        HStack {
            if count > 0 {
                Text("▼ \(count) \(noun)")
                    .font(Theme.stampFont)
                    .monospacedDigit()
                    .foregroundStyle(palette.muted)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .help(count == 0 ? "Nothing older in \(lane.title)" : "Scroll down. Older \(lane.title.lowercased()) stay on their original days.")
    }
}
