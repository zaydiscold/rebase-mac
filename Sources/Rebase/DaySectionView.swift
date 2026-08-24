import SwiftUI

struct DayFrameKey: PreferenceKey {
    static let defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct DaySectionView: View {
    let day: PrototypeDay
    var onToggle: ((String, Lane, String) -> Void)?
    var onStar: ((String, Lane, String) -> Void)?
    @Environment(\.palette) private var palette
    @Environment(\.laneFractions) private var fractions

    var body: some View {
        VStack(spacing: 0) {
            LaneMaxHeightLayout(fractions: fractions) {
                LaneColumnView(entries: day.ideas, lane: .ideas, dayId: day.id, onToggle: onToggle, onStar: onStar)
                LaneColumnView(entries: day.life, lane: .life, dayId: day.id, onToggle: onToggle, onStar: onStar)
                LaneColumnView(entries: day.work, lane: .work, dayId: day.id, onToggle: onToggle, onStar: onStar)
            }
            DateDividerView(day: day)
        }
        .background(palette.paper)
        .overlay(alignment: .top) {
            LaneHairlines()
        }
        .background {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: DayFrameKey.self,
                    value: [day.id: proxy.frame(in: .scrollView(axis: .vertical))]
                )
            }
        }
    }
}
