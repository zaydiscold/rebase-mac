import AppKit
import SwiftUI

@main
struct RebaseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var state = AppState()
    @State private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            RootView(state: state, settings: settings)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1180, height: 780)
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
        }

        Settings {
            SettingsView(settings: settings)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.async {
            for window in NSApp.windows where window.canBecomeMain {
                window.makeKeyAndOrderFront(nil)
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
