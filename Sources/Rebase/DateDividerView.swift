import SwiftUI

struct DateDividerView: View {
    let day: PrototypeDay
    @State private var hovering = false
    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: 10) {
            Text(hovering ? day.fullDate : day.stamp)
                .font(Theme.stampFont)
                .monospacedDigit()
                .foregroundStyle(palette.muted)
                .padding(.leading, 16)
            Rectangle()
                .fill(palette.dateRule)
                .frame(height: 1)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 2)
        .padding(.bottom, 2)
        .onHover { hovering = $0 }
        .help(day.fullDate)
    }
}
