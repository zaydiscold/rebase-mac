import SwiftUI

struct Palette {
    let paper: Color
    let ink: Color
    let muted: Color
    let dateRule: Color
    let grainOpacity: Double

    static func make(_ scheme: ColorScheme) -> Palette {
        scheme == .light ? .light : .dark
    }

    static let dark = Palette(
        paper: Color(red: 0x2C / 255, green: 0x2E / 255, blue: 0x31 / 255),
        ink: Color(red: 0xD2 / 255, green: 0xD5 / 255, blue: 0xD8 / 255),
        muted: Color(red: 0x8E / 255, green: 0x93 / 255, blue: 0x97 / 255),
        dateRule: Color(red: 0xD2 / 255, green: 0xD5 / 255, blue: 0xD8 / 255).opacity(0.18),
        grainOpacity: 0.12
    )

    static let light = Palette(
        paper: Color(red: 0xF1 / 255, green: 0xE9 / 255, blue: 0xD2 / 255),
        ink: Color(red: 0x22 / 255, green: 0x22 / 255, blue: 0x22 / 255),
        muted: Color(red: 0x66 / 255, green: 0x66 / 255, blue: 0x66 / 255),
        dateRule: Color(red: 0x22 / 255, green: 0x22 / 255, blue: 0x22 / 255).opacity(0.14),
        grainOpacity: 0.05
    )
}

enum Accent: String, CaseIterable, Identifiable, Codable {
    case orange
    case violet
    case lilac
    case ice

    var id: String { rawValue }

    var title: String {
        switch self {
        case .orange: "Orange"
        case .violet: "Violet"
        case .lilac: "Lilac"
        case .ice: "Ice"
        }
    }

    var color: Color {
        switch self {
        case .orange: Color(red: 1, green: 0x80 / 255, blue: 0x40 / 255)
        case .violet: Color(red: 0x9B / 255, green: 0x7D / 255, blue: 1)
        case .lilac: Color(red: 0x98 / 255, green: 0x78 / 255, blue: 0xD0 / 255)
        case .ice: Color(red: 0x98 / 255, green: 0xD8 / 255, blue: 0xF8 / 255)
        }
    }

    var onColor: Color {
        self == .ice ? Color(red: 0.13, green: 0.14, blue: 0.16) : Color.white.opacity(0.94)
    }
}

enum Theme {
    static let star = Color(red: 0.90, green: 0.16, blue: 0.16)
    static let chromeFont = Font.system(size: 12, weight: .medium)
    static let stampFont = Font.system(size: 12, weight: .regular, design: .monospaced)
    static let motion = Animation.timingCurve(0.25, 0.46, 0.45, 0.94, duration: 0.18)
}

enum Lane: String, CaseIterable, Identifiable {
    case ideas, life, work
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

private struct PaletteKey: EnvironmentKey { static let defaultValue = Palette.dark }
private struct LaneFractionsKey: EnvironmentKey { static let defaultValue: [CGFloat] = [0.37, 0.37, 0.26] }
private struct BodySizeKey: EnvironmentKey { static let defaultValue: CGFloat = 16 }
private struct AccentKey: EnvironmentKey { static let defaultValue = Accent.violet }

extension EnvironmentValues {
    var palette: Palette {
        get { self[PaletteKey.self] }
        set { self[PaletteKey.self] = newValue }
    }
    var laneFractions: [CGFloat] {
        get { self[LaneFractionsKey.self] }
        set { self[LaneFractionsKey.self] = newValue }
    }
    var bodySize: CGFloat {
        get { self[BodySizeKey.self] }
        set { self[BodySizeKey.self] = newValue }
    }
    var accent: Accent {
        get { self[AccentKey.self] }
        set { self[AccentKey.self] = newValue }
    }
}
