import SwiftUI

struct LaneHeaderView: View {
    var body: some View {
        LaneMaxHeightLayout {
            header(.ideas)
            header(.life)
            header(.work)
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.hairline).frame(height: 1)
        }
        .overlay {
            GeometryReader { geo in
                let usable = geo.size.width - 2
                let x1 = (usable * Theme.ideasFraction).rounded(.down)
                let x2 = x1 + 1 + (usable * Theme.lifeFraction).rounded(.down)
                ZStack(alignment: .topLeading) {
                    Rectangle().fill(Theme.hairline).frame(width: 1, height: geo.size.height).offset(x: x1)
                    Rectangle().fill(Theme.hairline).frame(width: 1, height: geo.size.height).offset(x: x2)
                }
            }
            .allowsHitTesting(false)
        }
        .background(Theme.paper)
    }

    private func header(_ lane: Lane) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(lane.title.uppercased())
                .font(Theme.labelFont)
                .tracking(1.4)
                .foregroundStyle(Theme.muted)
            Spacer(minLength: 0)
            Text(lane.shortcut)
                .font(Theme.stampFont)
                .foregroundStyle(Theme.muted.opacity(0.7))
        }
        .padding(.leading, lane == .ideas ? 78 : 16)
        .padding(.trailing, 16)
        .padding(.top, 36)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
