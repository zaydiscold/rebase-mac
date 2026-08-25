import SwiftUI

struct DayFrameKey: PreferenceKey {
    static let defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct DaySectionView: View {
    let day: PrototypeDay
    var expanded: Bool
    var onToggleDay: () -> Void
    var onToggle: ((String, Lane, String) -> Void)?
    var onStar: ((String, Lane, String) -> Void)?
    var onEdit: ((String, Lane, String, String) -> Void)?
    @Environment(\.palette) private var palette
    @Environment(\.laneFractions) private var fractions

    var body: some View {
        VStack(spacing: 0) {
            DateDividerView(day: day, collapsed: !expanded, onToggle: onToggleDay)

            if expanded {
                LaneMaxHeightLayout(fractions: fractions) {
                    LaneColumnView(entries: day.ideas, lane: .ideas, dayId: day.id, onToggle: onToggle, onStar: onStar, onEdit: onEdit)
                    LaneColumnView(entries: day.life, lane: .life, dayId: day.id, onToggle: onToggle, onStar: onStar, onEdit: onEdit)
                    LaneColumnView(entries: day.work, lane: .work, dayId: day.id, onToggle: onToggle, onStar: onStar, onEdit: onEdit)
                }
                .overlay { LaneHairlines() }
                .padding(.top, 6)
                .padding(.bottom, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .clipped()
        .animation(Theme.motion, value: expanded)
        .background(palette.paper)
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
