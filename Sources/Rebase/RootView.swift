import AppKit
import SwiftUI

struct RootView: View {
    @Bindable var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            LaneHeaderView()
            TimelineView()
            EdgeIndicatorView()
            CaptureBarView(selectedLane: $state.selectedLane, draft: $state.draft)
        }
        .background(Theme.paper)
        .background(WindowStylist())
        .preferredColorScheme(.dark)
    }
}

private struct WindowStylist: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            window.backgroundColor = NSColor(Theme.paper)
            window.titlebarAppearsTransparent = true
            window.isMovableByWindowBackground = true
            window.title = "Rebase"
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        nsView.window?.backgroundColor = NSColor(Theme.paper)
    }
}
