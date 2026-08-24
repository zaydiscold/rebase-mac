import SwiftUI

struct EdgeIndicatorView: View {
    var body: some View {
        LaneMaxHeightLayout {
            chip(lane: .ideas, count: PrototypeData.olderOpen[.ideas] ?? 0, noun: "older ideas")
            chip(lane: .life, count: PrototypeData.olderOpen[.life] ?? 0, noun: "open")
            chip(lane: .work, count: PrototypeData.olderOpen[.work] ?? 0, noun: "open")
        }
        .padding(.vertical, 8)
        .background(Theme.paper.opacity(0.96))
        .overlay(alignment: .top) {
            Rectangle().fill(Theme.hairline).frame(height: 1)
        }
    }

    private func chip(lane: Lane, count: Int, noun: String) -> some View {
        HStack {
            Text("▼ \(count) \(noun)")
                .font(Theme.stampFont)
                .monospacedDigit()
                .foregroundStyle(Theme.muted)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .help("Older \(lane.title.lowercased()) remain on their original days")
    }
}
