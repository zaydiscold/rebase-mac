import SwiftUI

struct DateDividerView: View {
    let day: PrototypeDay
    var collapsed: Bool
    var onToggle: () -> Void
    @State private var hovering = false
    @Environment(\.palette) private var palette
    @Environment(\.accent) private var accent

    var body: some View {
        Button {
            withAnimation(Theme.motion) {
                onToggle()
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: collapsed ? "chevron.right" : "chevron.down")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(chevronColor)
                    .frame(width: 10)
                    .padding(.leading, 14)

                Text(displayDate)
                    .font(dateFont)
                    .monospacedDigit()
                    .foregroundStyle(dateColor)

                stateIndicator

                Rectangle()
                    .fill(accent.color.opacity(ruleOpacity))
                    .frame(height: 1)
                    .animation(Theme.motion, value: ruleOpacity)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 7)
            .padding(.bottom, 7)
            .padding(.trailing, 14)
            .background(rowBackground)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .help(collapsed ? "Expand \(day.fullDate) downward" : "Collapse \(day.fullDate)")
        .accessibilityLabel(accessibilityDescription)
    }

    @ViewBuilder
    private var stateIndicator: some View {
        if openTotal > 0 {
            HStack(spacing: 5) {
                lanePips
                if collapsed {
                    Text("\(openTotal) open")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(palette.muted.opacity(0.88))
                        .monospacedDigit()
                }
            }
            .transition(.opacity)
        } else if day.isEmpty {
            Circle()
                .stroke(palette.muted.opacity(collapsed ? 0.30 : 0.48), lineWidth: 1)
                .frame(width: 5, height: 5)
                .help("Empty day")
        } else {
            Image(systemName: "checkmark")
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(palette.muted.opacity(0.62))
                .help("No open entries")
        }
    }

    private var lanePips: some View {
        HStack(spacing: 4) {
            pip(openCounts.ideas > 0)
            pip(openCounts.life > 0)
            pip(openCounts.work > 0)
        }
    }

    private func pip(_ hasOpenEntry: Bool) -> some View {
        Circle()
            .fill(hasOpenEntry ? palette.ink.opacity(0.78) : palette.muted.opacity(0.16))
            .frame(width: 4, height: 4)
    }

    private var displayDate: String {
        collapsed && !hovering ? day.stamp : day.fullDate
    }

    private var dateFont: Font {
        if !collapsed {
            return .system(size: 12, weight: .semibold, design: .serif)
        }
        if hovering {
            return .system(size: 12, weight: .medium, design: .serif)
        }
        return Theme.stampFont
    }

    private var openCounts: (ideas: Int, life: Int, work: Int) {
        (
            day.ideas.filter { !$0.done }.count,
            day.life.filter { !$0.done }.count,
            day.work.filter { !$0.done }.count
        )
    }

    private var openTotal: Int {
        openCounts.ideas + openCounts.life + openCounts.work
    }

    private var dateColor: Color {
        if !collapsed {
            return accent.color
        }
        if openTotal > 0 {
            return palette.ink.opacity(0.82)
        }
        return palette.muted.opacity(day.isEmpty ? 0.52 : 0.70)
    }

    private var chevronColor: Color {
        if !collapsed {
            return accent.color.opacity(0.90)
        }
        return palette.muted.opacity(openTotal > 0 || hovering ? 0.82 : 0.38)
    }

    private var ruleOpacity: Double {
        if !collapsed { return 0.48 }
        if openTotal > 0 { return 0.34 }
        if day.isEmpty { return 0.11 }
        return 0.20
    }

    private var rowBackground: Color {
        if !collapsed {
            return accent.color.opacity(0.075)
        }
        if openTotal > 0 {
            return accent.color.opacity(hovering ? 0.045 : 0.020)
        }
        return hovering ? palette.ink.opacity(0.025) : Color.clear
    }

    private var accessibilityDescription: String {
        if openTotal > 0 {
            return "\(day.fullDate), \(openTotal) open entries, \(collapsed ? "collapsed" : "expanded")"
        }
        if day.isEmpty {
            return "\(day.fullDate), empty, \(collapsed ? "collapsed" : "expanded")"
        }
        return "\(day.fullDate), no open entries, \(collapsed ? "collapsed" : "expanded")"
    }
}
