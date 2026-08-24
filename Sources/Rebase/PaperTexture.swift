import SwiftUI

struct PaperTexture: View {
    @Environment(\.palette) private var palette

    var body: some View {
        Image("grain", bundle: .module)
            .resizable(resizingMode: .tile)
            .opacity(palette.grainOpacity)
            .blendMode(.softLight)
            .allowsHitTesting(false)
            .ignoresSafeArea()
    }
}

struct LaneHairlines: View {
    @Environment(\.laneFractions) private var fractions
    @Environment(\.palette) private var palette
    @Environment(\.accent) private var accent

    var body: some View {
        GeometryReader { geo in
            let ideas = fractions.indices.contains(0) ? fractions[0] : 0.37
            let life = fractions.indices.contains(1) ? fractions[1] : 0.37
            let usable = geo.size.width - 2
            let x1 = (usable * ideas).rounded(.down)
            let x2 = x1 + 1 + (usable * life).rounded(.down)
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(accent.color.opacity(0.30))
                    .frame(width: 1, height: geo.size.height)
                    .offset(x: x1)
                Rectangle()
                    .fill(accent.color.opacity(0.30))
                    .frame(width: 1, height: geo.size.height)
                    .offset(x: x2)
            }
        }
        .allowsHitTesting(false)
    }
}
