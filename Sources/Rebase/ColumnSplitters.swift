import SwiftUI

struct ColumnSplitters: View {
    @Bindable var settings: AppSettings
    @State private var startIdeas: Double?
    @State private var startLife: Double?

    var body: some View {
        GeometryReader { geo in
            let fractions = settings.fractions
            let x1 = geo.size.width * fractions[0]
            let x2 = x1 + geo.size.width * fractions[1]
            HStack(spacing: 0) {
                Color.clear
                    .frame(width: max(0, x1 - 4))
                    .allowsHitTesting(false)
                grip(height: geo.size.height) { dx in
                    if startIdeas == nil { startIdeas = settings.ideasShare }
                    settings.setIdeas((startIdeas ?? settings.ideasShare) + Double(dx / geo.size.width))
                } onEnd: {
                    startIdeas = nil
                }
                Color.clear
                    .frame(width: max(0, (x2 - x1) - 8))
                    .allowsHitTesting(false)
                grip(height: geo.size.height) { dx in
                    if startLife == nil { startLife = settings.lifeShare }
                    settings.setLife((startLife ?? settings.lifeShare) + Double(dx / geo.size.width))
                } onEnd: {
                    startLife = nil
                }
                Color.clear
                    .frame(maxWidth: .infinity)
                    .allowsHitTesting(false)
            }
        }
    }

    private func grip(height: CGFloat, onDrag: @escaping (CGFloat) -> Void, onEnd: @escaping () -> Void) -> some View {
        Rectangle()
            .fill(.clear)
            .frame(width: 8, height: height)
            .contentShape(Rectangle())
            .pointerStyle(.columnResize)
            .gesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { value in onDrag(value.translation.width) }
                    .onEnded { _ in onEnd() }
            )
    }
}
