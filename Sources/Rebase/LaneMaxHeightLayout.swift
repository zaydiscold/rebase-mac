import SwiftUI

/// Three parallel lanes. Height is the tallest lane. Shorter lanes keep blank paper.
struct LaneMaxHeightLayout: Layout {
    var fractions: [CGFloat] = [Theme.ideasFraction, Theme.lifeFraction, Theme.workFraction]
    var hairline: CGFloat = 1

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 800
        let laneWidths = widths(for: width)
        var maxHeight: CGFloat = 0
        for (index, subview) in subviews.enumerated() {
            guard index < laneWidths.count else { break }
            let height = subview.sizeThatFits(
                ProposedViewSize(width: laneWidths[index], height: nil)
            ).height
            maxHeight = max(maxHeight, height)
        }
        return CGSize(width: width, height: maxHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let laneWidths = widths(for: bounds.width)
        var x = bounds.minX
        for (index, subview) in subviews.enumerated() {
            guard index < laneWidths.count else { break }
            let width = laneWidths[index]
            subview.place(
                at: CGPoint(x: x, y: bounds.minY),
                proposal: ProposedViewSize(width: width, height: bounds.height)
            )
            x += width + hairline
        }
    }

    private func widths(for total: CGFloat) -> [CGFloat] {
        let usable = max(0, total - hairline * CGFloat(max(fractions.count - 1, 0)))
        return fractions.map { ($0 * usable).rounded(.down) }
    }
}
