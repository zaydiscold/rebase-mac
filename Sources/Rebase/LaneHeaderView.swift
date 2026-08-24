import SwiftUI

struct LaneHeaderView: View {
    @Binding var selectedLane: Lane
    @Environment(\.palette) private var palette
    @Environment(\.laneFractions) private var fractions

    var body: some View {
        LaneMaxHeightLayout(fractions: fractions) {
            header(.ideas)
            header(.life)
            header(.work)
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(palette.dateRule).frame(height: 1)
        }
        .overlay {
            LaneHairlines()
        }
        .background(palette.paper)
    }

    private func header(_ lane: Lane) -> some View {
        let selected = selectedLane == lane
        return Button {
            selectedLane = lane
        } label: {
            Text(lane.title.uppercased())
                .font(.system(size: 13, weight: .bold, design: .default))
                .tracking(1.6)
                .foregroundStyle(selected ? palette.ink : palette.ink.opacity(0.78))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, lane == .ideas ? 78 : 16)
                .padding(.trailing, 16)
                .padding(.top, 36)
                .padding(.bottom, 10)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("\(lane.shortcut) — next Return goes to \(lane.title)")
    }
}
