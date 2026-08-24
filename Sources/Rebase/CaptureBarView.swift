import SwiftUI

struct CaptureBarView: View {
    @Binding var selectedLane: Lane
    @Binding var draft: String
    @Binding var draftImportant: Bool
    var onSubmit: () -> Void
    @Environment(\.palette) private var palette
    @Environment(\.accent) private var accent
    @Environment(\.bodySize) private var bodySize

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            SettingsLink {
                Image(systemName: "gearshape")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(palette.muted.opacity(0.55))
                    .frame(width: 18, height: 18)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Settings  ⌘,")

            HStack(spacing: 2) {
                ForEach(Lane.allCases) { lane in
                    laneButton(lane)
                }
            }

            Button {
                draftImportant.toggle()
            } label: {
                Image(systemName: "asterisk")
                    .font(.system(size: 10, weight: draftImportant ? .black : .bold))
                    .foregroundStyle(draftImportant ? Theme.star : palette.muted.opacity(0.45))
                    .frame(width: 18, height: 18)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(draftImportant ? "Add as normal" : "Mark important")
            .accessibilityLabel(draftImportant ? "Important task" : "Normal task")

            CaptureField(
                text: $draft,
                onSubmit: onSubmit,
                ink: palette.ink,
                muted: palette.muted,
                bodySize: bodySize
            )
            .frame(minHeight: 20)

            Button(action: onSubmit) {
                Image(systemName: "arrow.uturn.up")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(palette.muted)
                    .frame(width: 22, height: 20)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Add to \(selectedLane.title)")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(palette.paper)
        .overlay(alignment: .top) {
            Rectangle().fill(accent.color.opacity(0.34)).frame(height: 1)
        }
    }

    private func laneButton(_ lane: Lane) -> some View {
        let selected = selectedLane == lane
        return Button {
            selectedLane = lane
        } label: {
            Text(lane.title.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .tracking(0.7)
                .foregroundStyle(selected ? accent.color : palette.muted)
                .padding(.horizontal, 5)
                .padding(.vertical, 3)
                .background(selected ? accent.color.opacity(0.12) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("\(lane.shortcut) selects \(lane.title)")
    }
}
