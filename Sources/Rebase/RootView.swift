import AppKit
import SwiftUI

struct RootView: View {
    @Bindable var state: AppState
    @Bindable var settings: AppSettings
    @Environment(\.colorScheme) private var systemScheme

    private var scheme: ColorScheme { settings.colorScheme ?? systemScheme }
    private var palette: Palette { Palette.make(scheme) }
    private var older: [Lane: Int] { state.olderCounts(in: state.visibleRect) }
    private var showOlder: Bool { older.values.contains { $0 > 0 } }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                LaneHeaderView(selectedLane: $state.selectedLane)
                TimelineView(state: state)
                if showOlder {
                    EdgeIndicatorView(below: older)
                }
            }
            .overlay { ColumnSplitters(settings: settings) }
            CaptureBarView(
                selectedLane: $state.selectedLane,
                draft: $state.draft,
                draftImportant: $state.draftImportant,
                onSubmit: { state.capture() }
            )
        }
        .frame(minWidth: 900, minHeight: 560)
        .background(palette.paper)
        .overlay { PaperTexture() }
        .background(WindowStylist(paper: palette.paper))
        .environment(\.palette, palette)
        .environment(\.accent, settings.accent)
        .environment(\.laneFractions, settings.fractions)
        .environment(\.bodySize, CGFloat(settings.bodySize))
        .preferredColorScheme(settings.colorScheme)
    }
}

private struct WindowStylist: NSViewRepresentable {
    var paper: Color

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async { Self.apply(view.window, paper: paper) }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        Self.apply(nsView.window, paper: paper)
    }

    @MainActor
    static func apply(_ window: NSWindow?, paper: Color) {
        guard let window else { return }
        window.backgroundColor = NSColor(paper)
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = false
        window.title = "Rebase"
        window.subtitle = "To-do list triage"
        window.minSize = NSSize(width: 900, height: 560)
        window.isRestorable = false
        if window.frame.width < 800 || window.frame.height < 500 {
            if let screen = window.screen ?? NSScreen.main {
                let visible = screen.visibleFrame
                let size = NSSize(width: 1180, height: 780)
                let origin = NSPoint(
                    x: visible.midX - size.width / 2,
                    y: visible.midY - size.height / 2
                )
                window.setFrame(NSRect(origin: origin, size: size), display: true)
            }
        }
    }
}
