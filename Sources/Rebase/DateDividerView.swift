import SwiftUI

struct DateDividerView: View {
    let day: PrototypeDay
    var collapsed: Bool
    var onToggle: () -> Void
    @State private var hovering = false
    @Environment(\.palette) private var palette
    @Environment(\.accent) private var accent

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 10) {
                Text(hovering ? day.fullDate : day.stamp)
                    .font(Theme.stampFont)
                    .monospacedDigit()
                    .foregroundStyle(palette.muted)
                    .padding(.leading, 16)
                occupancy
                Rectangle()
                    .fill(accent.color.opacity(0.34))
                    .frame(height: 1)
                Image(systemName: collapsed ? "chevron.right" : "chevron.down")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(palette.muted.opacity(hovering || collapsed ? 0.9 : 0.35))
                    .padding(.trailing, 14)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 7)
            .padding(.bottom, 7)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .help(collapsed ? "Expand \(day.stamp)" : "Collapse \(day.stamp)")
    }

    private var occupancy: some View {
        HStack(spacing: 4) {
            pip(day.ideas.contains { !$0.done })
            pip(day.life.contains { !$0.done })
            pip(day.work.contains { !$0.done })
        }
        .opacity(collapsed || hovering ? 1 : 0)
        .animation(Theme.motion, value: collapsed)
        .animation(Theme.motion, value: hovering)
    }

    private func pip(_ hasOpenEntry: Bool) -> some View {
        Circle()
            .fill(hasOpenEntry ? palette.ink.opacity(0.75) : Color.clear)
            .frame(width: 4, height: 4)
    }
}
