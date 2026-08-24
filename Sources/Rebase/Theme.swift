import SwiftUI

enum Theme {
    static let paper = Color(red: 0x36 / 255, green: 0x3B / 255, blue: 0x40 / 255)
    static let paper2 = Color(red: 0x2E / 255, green: 0x30 / 255, blue: 0x33 / 255)
    static let ink = Color(red: 0xB8 / 255, green: 0xBF / 255, blue: 0xC6 / 255)
    static let muted = Color(red: 0x8A / 255, green: 0x91 / 255, blue: 0x98 / 255)
    static let hairline = Color(red: 0x55 / 255, green: 0x55 / 255, blue: 0x55 / 255)
    static let caret = Color(red: 0x6D / 255, green: 0xC1 / 255, blue: 0xE7 / 255)
    static let select = Color(red: 0x4A / 255, green: 0x89 / 255, blue: 0xDC / 255)

    static let ideasFraction: CGFloat = 0.37
    static let lifeFraction: CGFloat = 0.37
    static let workFraction: CGFloat = 0.26

    static let bodyFont = Font.system(size: 16, weight: .regular, design: .serif)
    static let chromeFont = Font.system(size: 12, weight: .medium)
    static let stampFont = Font.system(size: 12, weight: .regular, design: .monospaced)
    static let labelFont = Font.system(size: 11, weight: .semibold)
}

enum Lane: String, CaseIterable, Identifiable {
    case ideas
    case life
    case work

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ideas: "Ideas"
        case .life: "Life"
        case .work: "Work"
        }
    }

    var widthFraction: CGFloat {
        switch self {
        case .ideas: Theme.ideasFraction
        case .life: Theme.lifeFraction
        case .work: Theme.workFraction
        }
    }

    var shortcut: String {
        switch self {
        case .ideas: "⌘1"
        case .life: "⌘2"
        case .work: "⌘3"
        }
    }
}
