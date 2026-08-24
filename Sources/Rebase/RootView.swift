import AppKit
import SwiftUI

struct RootView: View {
    @Bindable var state: AppState
    @Bindable var settings: AppSettings
    @Environment(\.colorScheme) private var systemScheme

    private var scheme: ColorScheme {
        settings.colorScheme ?? systemScheme
    }

    private var palette: Palette {
        Palette.make(scheme)
    }

    var body: some View {
        VStack(spacing: 0) {
            LaneHeaderView(selectedLane: $state.selectedLane)
            TimelineView(state: state)
            EdgeIndicatorView(below: state.counts(relativeTo: state.visibleRect, below: true))
            CaptureBarView(
                selectedLane: $state.selectedLane,
                draft: $state.draft,
                onSubmit: { state.capture() }
            )
        }
        .background(palette.paper)
        .overlay { PaperTexture() }
        .background(WindowStylist(paper: palette.paper))
        .environment(\.palette, palette)
        .environment(\.laneFractions, settings.fractions)
        .preferredColorScheme(settings.colorScheme)
    }
}

private struct WindowStylist: NSViewRepresentable {
    var paper: Color

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            apply(view.window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        apply(nsView.window)
    }

    private func apply(_ window: NSWindow?) {
        guard let window else { return }
        window.backgroundColor = NSColor(paper)
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.title = "Rebase"
    }
}
