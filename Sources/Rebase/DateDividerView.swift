import SwiftUI

struct DateDividerView: View {
    let day: PrototypeDay
    @State private var hovering = false

    var body: some View {
        HStack(spacing: 12) {
            Text(hovering ? day.fullDate : day.stamp)
                .font(Theme.stampFont)
                .monospacedDigit()
                .foregroundStyle(Theme.muted)
                .padding(.leading, 16)
                .animation(.easeOut(duration: 0.12), value: hovering)
            Rectangle()
                .fill(Theme.hairline)
                .frame(height: 1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .onHover { hovering = $0 }
        .help(day.fullDate)
    }
}
