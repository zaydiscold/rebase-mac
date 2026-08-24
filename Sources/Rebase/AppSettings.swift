import AppKit
import Foundation
import SwiftUI
import UniformTypeIdentifiers

enum AppearanceMode: String, Codable, CaseIterable, Identifiable {
    case system, dark, light
    var id: String { rawValue }
    var title: String {
        switch self {
        case .system: "System"
        case .dark: "Dark"
        case .light: "Light"
        }
    }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .dark: .dark
        case .light: .light
        }
    }
}

@Observable
final class AppSettings {
    var appearance: AppearanceMode = .dark { didSet { save() } }
    var accent: Accent = .violet { didSet { save() } }
    var ideasShare: Double = 0.37 { didSet { save() } }
    var lifeShare: Double = 0.37 { didSet { save() } }
    var bodySize: Double = 16 { didSet { save() } }
    var checksForUpdatesAutomatically = true { didSet { save() } }

    var colorScheme: ColorScheme? { appearance.colorScheme }

    var workShare: Double { max(Self.minWork, 1 - ideasShare - lifeShare) }

    var fractions: [CGFloat] {
        let work = workShare
        let total = ideasShare + lifeShare + work
        return [CGFloat(ideasShare / total), CGFloat(lifeShare / total), CGFloat(work / total)]
    }

    init() {
        guard let loaded = Self.load() else { return }
        let shares = Self.normalizedColumnShares(
            ideas: loaded.ideasShare,
            life: loaded.lifeShare
        )

        appearance = loaded.appearance
        accent = loaded.accent ?? .violet
        ideasShare = shares.ideas
        lifeShare = shares.life
        bodySize = Self.normalizedBodySize(loaded.bodySize)
        checksForUpdatesAutomatically = loaded.checksForUpdatesAutomatically ?? true

        // Persist repaired values and fill optional defaults from older settings files.
        save()
    }

    static func normalizedColumnShares(ideas: Double, life: Double) -> (ideas: Double, life: Double) {
        let safeIdeas = ideas.isFinite ? ideas : 0.37
        let safeLife = life.isFinite ? life : 0.37
        var normalizedIdeas = min(1 - minLane - minWork, max(minLane, safeIdeas))
        var normalizedLife = min(1 - minLane - minWork, max(minLane, safeLife))
        let available = 1 - minWork

        if normalizedIdeas + normalizedLife > available {
            let ideasFlex = normalizedIdeas - minLane
            let lifeFlex = normalizedLife - minLane
            let flexibleTotal = ideasFlex + lifeFlex
            let flexibleAvailable = available - (2 * minLane)

            if flexibleTotal > 0 {
                let scale = flexibleAvailable / flexibleTotal
                normalizedIdeas = minLane + (ideasFlex * scale)
                normalizedLife = minLane + (lifeFlex * scale)
            }
        }

        return (normalizedIdeas, normalizedLife)
    }

    static func normalizedBodySize(_ value: Double?) -> Double {
        guard let value, value.isFinite else { return 16 }
        return min(maxBody, max(minBody, value))
    }

    func resetColumns() {
        ideasShare = 0.37
        lifeShare = 0.37
    }

    func resetBodySize() { bodySize = 16 }

    func adjustBodySize(_ delta: Double) {
        bodySize = min(Self.maxBody, max(Self.minBody, (bodySize + delta).rounded()))
    }

    func setIdeas(_ value: Double) {
        ideasShare = clamp(value)
        if ideasShare + lifeShare > 1 - Self.minWork {
            lifeShare = 1 - Self.minWork - ideasShare
        }
    }

    func setLife(_ value: Double) {
        lifeShare = clamp(value)
        if ideasShare + lifeShare > 1 - Self.minWork {
            ideasShare = 1 - Self.minWork - lifeShare
        }
    }

    private func clamp(_ value: Double) -> Double {
        guard value.isFinite else { return 0.37 }
        return min(1 - Self.minLane - Self.minWork, max(Self.minLane, value))
    }

    private static let minLane = 0.18
    private static let minWork = 0.16
    static let minBody: Double = 13
    static let maxBody: Double = 22

    private struct File: Codable {
        var appearance: AppearanceMode
        var accent: Accent?
        var ideasShare: Double
        var lifeShare: Double
        var bodySize: Double?
        var checksForUpdatesAutomatically: Bool?
    }

    private static var fileURL: URL { NotesStore.folder.appendingPathComponent("settings.json") }

    private static func load() -> File? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(File.self, from: data)
    }

    private func save() {
        let file = File(
            appearance: appearance,
            accent: accent,
            ideasShare: ideasShare,
            lifeShare: lifeShare,
            bodySize: bodySize,
            checksForUpdatesAutomatically: checksForUpdatesAutomatically
        )
        guard let data = try? JSONEncoder().encode(file) else { return }
        try? data.write(to: Self.fileURL, options: .atomic)
    }
}

enum NotesStore {
    static var folder: URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Rebase", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        writeReadmeIfNeeded(in: url)
        return url
    }

    static var daysURL: URL { folder.appendingPathComponent("days.json") }
    static var markdownURL: URL { folder.appendingPathComponent("rebase.md") }

    private static var legacyDaysURL: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Rebase", isDirectory: true)
            .appendingPathComponent("days.json")
    }

    static func loadDays() -> [PrototypeDay]? {
        if let data = try? Data(contentsOf: daysURL),
           let days = try? JSONDecoder().decode([PrototypeDay].self, from: data) {
            return days
        }
        if let data = try? Data(contentsOf: legacyDaysURL),
           let days = try? JSONDecoder().decode([PrototypeDay].self, from: data) {
            try? data.write(to: daysURL, options: .atomic)
            return days
        }
        return nil
    }

    static func saveDays(_ days: [PrototypeDay]) {
        let captured = days.filter { !$0.isEmpty }
        if let data = try? JSONEncoder().encode(captured) {
            try? data.write(to: daysURL, options: .atomic)
        }
        try? RebaseMarkdown.render(captured).write(to: markdownURL, atomically: true, encoding: .utf8)
    }

    static func revealInFinder() {
        NSWorkspace.shared.activateFileViewerSelecting([folder])
    }

    @MainActor
    static func exportMarkdown(_ days: [PrototypeDay]) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        panel.nameFieldStringValue = "rebase.md"
        panel.canCreateDirectories = true
        guard panel.runModal() == .OK, let url = panel.url else { return }
        try? RebaseMarkdown.render(days).write(to: url, atomically: true, encoding: .utf8)
    }

    @MainActor
    static func importMarkdown() -> [PrototypeDay]? {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.plainText]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        guard panel.runModal() == .OK, let url = panel.url else { return nil }

        do {
            let text = try String(contentsOf: url, encoding: .utf8)
            let parsed = try RebaseMarkdown.parse(text)
            return parsed.isEmpty ? nil : parsed
        } catch {
            showImportError(error)
            return nil
        }
    }

    @MainActor
    private static func showImportError(_ error: Error) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Could not import Rebase Markdown"
        alert.informativeText = error.localizedDescription
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private static func writeReadmeIfNeeded(in folder: URL) {
        let readme = folder.appendingPathComponent("README.txt")
        guard !FileManager.default.fileExists(atPath: readme.path) else { return }
        let text = """
        Rebase stores your notes here, not inside the app.

        days.json   source of truth (Ideas / Life / Work)
        rebase.md   same notes as markdown, for a work computer or an agent
        settings.json   appearance, accent, columns, type size, update checks

        Rebuilding the app does not touch this folder.
        Timezone grouping is America/Los_Angeles.
        """
        try? text.write(to: readme, atomically: true, encoding: .utf8)
    }
}
