import SwiftUI

struct Palette {
    let paper: Color
    let paper2: Color
    let ink: Color
    let muted: Color
    let dateRule: Color

    static let dark = Palette(
        paper: Color(red: 0x1F / 255, green: 0x1D / 255, blue: 0x18 / 255),
        paper2: Color(red: 0x16 / 255, green: 0x14 / 255, blue: 0x10 / 255),
        ink: Color(red: 0xF1 / 255, green: 0xE9 / 255, blue: 0xD2 / 255),
        muted: Color(red: 0xC9 / 255, green: 0xC1 / 255, blue: 0xAB / 255),
        dateRule: Color(red: 0xF1 / 255, green: 0xE9 / 255, blue: 0xD2 / 255).opacity(0.32)
    )

    static let light = Palette(
        paper: Color(red: 0xF1 / 255, green: 0xE9 / 255, blue: 0xD2 / 255),
        paper2: Color(red: 0xE6 / 255, green: 0xDC / 255, blue: 0xC0 / 255),
        ink: Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255),
        muted: Color(red: 0x55 / 255, green: 0x55 / 255, blue: 0x55 / 255),
        dateRule: Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255).opacity(0.22)
    )

    static func make(_ scheme: ColorScheme) -> Palette {
        scheme == .light ? .light : .dark
    }
}

private struct PaletteKey: EnvironmentKey {
    static let defaultValue = Palette.dark
}

private struct LaneFractionsKey: EnvironmentKey {
    static let defaultValue: [CGFloat] = [0.37, 0.37, 0.26]
}

extension EnvironmentValues {
    var palette: Palette {
        get { self[PaletteKey.self] }
        set { self[PaletteKey.self] = newValue }
    }

    var laneFractions: [CGFloat] {
        get { self[LaneFractionsKey.self] }
        set { self[LaneFractionsKey.self] = newValue }
    }
}

enum Theme {
    static let orange = Color(red: 0xFF / 255, green: 0x80 / 255, blue: 0x40 / 255)
    static let purple = Color(red: 0x9B / 255, green: 0x7D / 255, blue: 0xFF / 255)
    static let star = Color(red: 0xE5 / 255, green: 0x3E / 255, blue: 0x3E / 255)
    static let bodyFont = Font.system(size: 16, weight: .regular, design: .serif)
    static let chromeFont = Font.system(size: 12, weight: .medium)
    static let stampFont = Font.system(size: 12, weight: .regular, design: .monospaced)
    /// anime.js easeOutQuad, 220ms. Transform and opacity only.
    static let motion = Animation.timingCurve(0.25, 0.46, 0.45, 0.94, duration: 0.22)
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

    var shortcut: String {
        switch self {
        case .ideas: "⌘1"
        case .life: "⌘2"
        case .work: "⌘3"
        }
    }
}
