import SwiftUI

struct CaptureBarView: View {
    @Binding var selectedLane: Lane
    @Binding var draft: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            HStack(spacing: 4) {
                ForEach(Lane.allCases) { lane in
                    laneButton(lane)
                }
            }

            TextField("Write anything…", text: $draft, axis: .vertical)
                .textFieldStyle(.plain)
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.ink)
                .lineLimit(1...5)

            Text("Return ↵")
                .font(Theme.stampFont)
                .foregroundStyle(Theme.muted)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Theme.paper2)
        .overlay(alignment: .top) {
            Rectangle().fill(Theme.hairline).frame(height: 1)
        }
    }

    private func laneButton(_ lane: Lane) -> some View {
        let selected = selectedLane == lane
        return Button {
            selectedLane = lane
        } label: {
            Text(lane.title)
                .font(Theme.chromeFont)
                .foregroundStyle(selected ? Theme.paper : Theme.ink)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(selected ? Theme.caret : Color.clear)
                .overlay {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(selected ? Color.clear : Theme.hairline, lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        }
        .buttonStyle(.plain)
        .help("\(lane.title) \(lane.shortcut)")
    }
}
