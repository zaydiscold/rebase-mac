import AppKit
import SwiftUI

@main
struct RebaseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var state = AppState()

    var body: some Scene {
        WindowGroup {
            RootView(state: state)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1180, height: 780)
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
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
