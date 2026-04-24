import SwiftUI
import UIKit

enum PreferredTheme: String, CaseIterable, Identifiable {
    case light
    case dark
    case system

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .system:
            return "System"
        }
    }

    var systemImage: String {
        switch self {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .system:
            return "circle.lefthalf.filled"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }

    static func resolved(from code: String?) -> PreferredTheme {
        guard let code else {
            return .system
        }

        return PreferredTheme(rawValue: code) ?? .system
    }
}

enum XPendoTheme {
    static let accentTeal = adaptiveColor(light: UIColor(hex: 0x00BFA5), dark: UIColor(hex: 0x25B0B9))
    static let coral = adaptiveColor(light: UIColor(hex: 0xE74C3C), dark: UIColor(hex: 0xFF5C5C))
    static let primaryText = adaptiveColor(light: UIColor(hex: 0x1C1C1E), dark: UIColor(hex: 0xFFFFFF))
    static let secondaryText = adaptiveColor(light: UIColor(hex: 0x8E8E93), dark: UIColor(hex: 0x8E8E93))
    static let background = adaptiveColor(light: UIColor(hex: 0xF8F9FA), dark: UIColor(hex: 0x0A0E12))
    static let surfaceBackground = adaptiveColor(light: UIColor(hex: 0xFFFFFF), dark: UIColor(hex: 0x1A1F24))
    static let inputBackground = adaptiveColor(light: UIColor(hex: 0xF1F4F6), dark: UIColor(hex: 0x13181D))
    static let selectedSurface = adaptiveColor(light: UIColor(hex: 0xFFFFFF), dark: UIColor(hex: 0x222831))
    static let housingGreen = adaptiveColor(light: UIColor(hex: 0x27AE60), dark: UIColor(hex: 0x4CD964))
    static let freshGreen = adaptiveColor(light: UIColor(hex: 0x2ECC71), dark: UIColor(hex: 0x4CD964))
    static let softPurple = adaptiveColor(light: UIColor(hex: 0x9B59B6), dark: UIColor(hex: 0xD65CF5))
    static let placeholder = adaptiveColor(light: UIColor(hex: 0xE6ECEF), dark: UIColor(hex: 0x2A3138))
    static let inactiveTab = adaptiveColor(light: UIColor(hex: 0x8E8E93), dark: UIColor(hex: 0x6E6E73))
    static let tabBarBackground = adaptiveColor(
        light: UIColor(hex: 0xFFFFFF, alpha: 0.98),
        dark: UIColor(hex: 0x0A0E12, alpha: 0.96)
    )
    static let cardBorder = adaptiveColor(
        light: UIColor.black.withAlphaComponent(0.04),
        dark: UIColor.white.withAlphaComponent(0.08)
    )
    static let cardShadow = adaptiveColor(
        light: UIColor.black.withAlphaComponent(0.08),
        dark: UIColor.black.withAlphaComponent(0.28)
    )

    private static func adaptiveColor(light: UIColor, dark: UIColor) -> Color {
        Color(
            uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? dark : light
            }
        )
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }

    init?(hexString: String, alpha: Double = 1.0) {
        let cleanedHex = hexString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        guard cleanedHex.count == 6, let hexValue = UInt(cleanedHex, radix: 16) else {
            return nil
        }

        self.init(hex: hexValue, alpha: alpha)
    }
}

private extension UIColor {
    convenience init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}
