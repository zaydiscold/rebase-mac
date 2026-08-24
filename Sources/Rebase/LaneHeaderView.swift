import SwiftUI

struct LaneHeaderView: View {
    @Binding var selectedLane: Lane
    @Environment(\.palette) private var palette
    @Environment(\.accent) private var accent
    @Environment(\.laneFractions) private var fractions

    var body: some View {
        VStack(spacing: 0) {
            LaneMaxHeightLayout(fractions: fractions) {
                header(.ideas)
                header(.life)
                header(.work)
            }
            .overlay { LaneHairlines() }
            Rectangle().fill(accent.color.opacity(0.34)).frame(height: 1)
        }
        .background(palette.paper)
    }

    private func header(_ lane: Lane) -> some View {
        let selected = selectedLane == lane
        return Button {
            selectedLane = lane
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(lane.title.uppercased())
                    .font(.system(size: 13, weight: .bold))
                    .tracking(1.6)
                    .foregroundStyle(selected ? accent.color : palette.ink.opacity(0.58))
                Rectangle()
                    .fill(selected ? accent.color : Color.clear)
                    .frame(width: 20, height: 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 30)
            .padding(.bottom, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("\(lane.shortcut). Next Return goes to \(lane.title)")
    }
}
