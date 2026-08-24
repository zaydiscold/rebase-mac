import SwiftUI

struct CaptureBarView: View {
    @Binding var selectedLane: Lane
    @Binding var draft: String
    var onSubmit: () -> Void
    @Environment(\.palette) private var palette

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            HStack(spacing: 4) {
                ForEach(Lane.allCases) { lane in
                    laneButton(lane)
                }
            }

            CaptureField(text: $draft, onSubmit: onSubmit, ink: palette.ink, muted: palette.muted)
                .frame(minHeight: 22)

            Button(action: onSubmit) {
                Image(systemName: "arrow.uturn.up")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(palette.ink)
                    .frame(width: 28, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Add to \(selectedLane.title)")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(palette.paper2)
        .overlay(alignment: .top) {
            Rectangle().fill(Theme.orange.opacity(0.45)).frame(height: 1)
        }
    }

    private func laneButton(_ lane: Lane) -> some View {
        let selected = selectedLane == lane
        return Button {
            selectedLane = lane
        } label: {
            HStack(spacing: 6) {
                Text(lane.title)
                    .font(Theme.chromeFont)
                Text(lane.shortcut)
                    .font(Theme.stampFont)
                    .opacity(selected ? 0.9 : 0.55)
            }
            .foregroundStyle(selected ? palette.paper : palette.ink)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(selected ? Theme.orange : Color.clear)
            .overlay {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(selected ? Color.clear : Theme.purple.opacity(0.55), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        }
        .buttonStyle(.plain)
        .help("\(lane.shortcut) writes the next Return into \(lane.title)")
    }
}
