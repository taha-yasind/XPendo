import SwiftUI

enum XPendoTheme {
    static let accentTeal = Color(hex: 0x00BFA5)
    static let coral = Color(hex: 0xE74C3C)
    static let primaryText = Color(hex: 0x1C1C1E)
    static let secondaryText = Color(hex: 0x8E8E93)
    static let background = Color(hex: 0xF8F9FA)
    static let housingGreen = Color(hex: 0x27AE60)
    static let freshGreen = Color(hex: 0x2ECC71)
    static let softPurple = Color(hex: 0x9B59B6)
    static let placeholder = Color(hex: 0xE6ECEF)
    static let cardBorder = Color.black.opacity(0.04)
    static let cardShadow = Color.black.opacity(0.08)
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
