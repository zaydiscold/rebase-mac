import SwiftUI

struct PaperTexture: View {
    var body: some View {
        Image("grain", bundle: .module)
            .resizable(resizingMode: .tile)
            .opacity(0.16)
            .blendMode(.softLight)
            .allowsHitTesting(false)
            .ignoresSafeArea()
    }
}

struct LaneHairlines: View {
    @Environment(\.laneFractions) private var fractions

    var body: some View {
        GeometryReader { geo in
            let ideas = fractions.indices.contains(0) ? fractions[0] : 0.37
            let life = fractions.indices.contains(1) ? fractions[1] : 0.37
            let usable = geo.size.width - 2
            let x1 = (usable * ideas).rounded(.down)
            let x2 = x1 + 1 + (usable * life).rounded(.down)
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Theme.orange.opacity(0.62))
                    .frame(width: 1, height: geo.size.height)
                    .offset(x: x1)
                Rectangle()
                    .fill(Theme.purple.opacity(0.62))
                    .frame(width: 1, height: geo.size.height)
                    .offset(x: x2)
            }
        }
        .allowsHitTesting(false)
    }
}
