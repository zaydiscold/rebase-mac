import AppKit
import SwiftUI

@main
struct RebaseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var state = AppState()
    @State private var settings = AppSettings()
    @State private var updates = UpdateChecker()

    var body: some Scene {
        WindowGroup {
            RootView(state: state, settings: settings)
                .task {
                    await updates.checkAutomatically(
                        enabled: settings.checksForUpdatesAutomatically
                    )
                }
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1180, height: 780)
        .windowResizability(.contentMinSize)
        .defaultLaunchBehavior(.presented)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandMenu("Lane") {
                Button("Ideas") { state.selectedLane = .ideas }
                    .keyboardShortcut("1", modifiers: .command)
                Button("Life") { state.selectedLane = .life }
                    .keyboardShortcut("2", modifiers: .command)
                Button("Work") { state.selectedLane = .work }
                    .keyboardShortcut("3", modifiers: .command)
            }
            CommandMenu("View") {
                Button("Bigger Text") { settings.adjustBodySize(1) }
                    .keyboardShortcut("=", modifiers: .command)
                Button("Smaller Text") { settings.adjustBodySize(-1) }
                    .keyboardShortcut("-", modifiers: .command)
                Button("Reset Text Size") { settings.resetBodySize() }
                    .keyboardShortcut("0", modifiers: .command)
                Divider()
                Button("Reset Column Widths") { settings.resetColumns() }
            }
        }

        Settings {
            SettingsView(settings: settings, state: state, updates: updates)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        UserDefaults.standard.set(false, forKey: "NSQuitAlwaysKeepsWindows")
        NSWindow.allowsAutomaticWindowTabbing = false
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.async { self.presentMainWindow() }
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        presentMainWindow()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    @MainActor
    private func presentMainWindow() {
        let windows = NSApp.windows.filter { $0.canBecomeMain }
        for window in windows {
            window.isRestorable = false
            window.minSize = NSSize(width: 900, height: 560)
            if window.frame.width < 800 || window.frame.height < 500 {
                let visible = (window.screen ?? NSScreen.main)?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
                let size = NSSize(width: 1180, height: 780)
                let frame = NSRect(
                    x: visible.midX - size.width / 2,
                    y: visible.midY - size.height / 2,
                    width: size.width,
                    height: size.height
                )
                window.setFrame(frame, display: true)
            }
            window.makeKeyAndOrderFront(nil)
        }
    }
}
