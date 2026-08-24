import AppKit
import Foundation
import SwiftUI

enum AppearanceMode: String, Codable, CaseIterable, Identifiable {
    case system
    case dark
    case light

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
    var appearance: AppearanceMode = .dark {
        didSet { save() }
    }
    var ideasShare: Double = 0.37 {
        didSet { save() }
    }
    var lifeShare: Double = 0.37 {
        didSet { save() }
    }

    var colorScheme: ColorScheme? { appearance.colorScheme }

    var workShare: Double {
        max(0.16, 1 - ideasShare - lifeShare)
    }

    var fractions: [CGFloat] {
        let work = workShare
        let total = ideasShare + lifeShare + work
        return [CGFloat(ideasShare / total), CGFloat(lifeShare / total), CGFloat(work / total)]
    }

    init() {
        if let loaded = Self.load() {
            appearance = loaded.appearance
            ideasShare = loaded.ideasShare
            lifeShare = loaded.lifeShare
        }
    }

    func resetColumns() {
        ideasShare = 0.37
        lifeShare = 0.37
    }

    private struct File: Codable {
        var appearance: AppearanceMode
        var ideasShare: Double
        var lifeShare: Double
    }

    private static var fileURL: URL {
        NotesStore.folder.appendingPathComponent("settings.json")
    }

    private static func load() -> File? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(File.self, from: data)
    }

    private func save() {
        let file = File(appearance: appearance, ideasShare: ideasShare, lifeShare: lifeShare)
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

    static var daysURL: URL {
        folder.appendingPathComponent("days.json")
    }

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
        let seededIds = Set(PrototypeData.sampleDays.map(\.id))
        let captured = days.filter { !$0.isEmpty || seededIds.contains($0.id) }
        guard let data = try? JSONEncoder().encode(captured) else { return }
        try? data.write(to: daysURL, options: .atomic)
    }

    static func revealInFinder() {
        NSWorkspace.shared.activateFileViewerSelecting([folder])
    }

    private static func writeReadmeIfNeeded(in folder: URL) {
        let readme = folder.appendingPathComponent("README.txt")
        guard !FileManager.default.fileExists(atPath: readme.path) else { return }
        let text = """
        Rebase stores your notes here, not inside the app.

        days.json       your Ideas / Life / Work entries
        settings.json   appearance and column widths

        Rebuilding the app, pulling from GitHub, or deleting Rebase.app
        does not touch this folder. Back this folder up if you care
        about the notes.

        Timezone grouping is America/Los_Angeles.
        """
        try? text.write(to: readme, atomically: true, encoding: .utf8)
    }
}
