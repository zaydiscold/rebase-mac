import SwiftUI

struct DaySectionView: View {
    let day: PrototypeDay

    var body: some View {
        VStack(spacing: 0) {
            LaneMaxHeightLayout {
                LaneColumnView(entries: day.ideas)
                LaneColumnView(entries: day.life)
                LaneColumnView(entries: day.work)
            }
            .background(Theme.paper)
            .overlay(alignment: .top) {
                laneHairlines
            }
            DateDividerView(day: day)
        }
    }

    private var laneHairlines: some View {
        GeometryReader { geo in
            let usable = geo.size.width - 2
            let x1 = (usable * Theme.ideasFraction).rounded(.down)
            let x2 = x1 + 1 + (usable * Theme.lifeFraction).rounded(.down)
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Theme.hairline)
                    .frame(width: 1, height: geo.size.height)
                    .offset(x: x1)
                Rectangle()
                    .fill(Theme.hairline)
                    .frame(width: 1, height: geo.size.height)
                    .offset(x: x2)
            }
        }
        .allowsHitTesting(false)
    }
}
