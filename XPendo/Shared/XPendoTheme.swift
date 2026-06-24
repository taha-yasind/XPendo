/*
 DOSYA: XPendoTheme.swift
 AMAÇ: Color, typography helper, spacing ve reusable style değerlerini merkezileştirir. Tüm SwiftUI ekranlarına shared visual language sağlar.
 KULLANAN: Tüm feature viewleri ve shared UI componentleri tarafından kullanılır.
*/
import SwiftUI
import UIKit

// PreferredTheme, Settings ekranında seçilen theme tercihini SwiftUI ColorScheme'e dönüştürür.
enum PreferredTheme: String, CaseIterable, Identifiable {
    case light
    case dark
    case system

    var id: String { rawValue }

    // Bu type için odaklı bir davranış parçasını yönetir.
    var displayName: String {
        switch self {
        case .light:
            return AppLocalization.string("theme.light")
        case .dark:
            return AppLocalization.string("theme.dark")
        case .system:
            return AppLocalization.string("theme.system")
        }
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
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

    // Bu type için odaklı bir davranış parçasını yönetir.
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

    // Bu type için odaklı bir davranış parçasını yönetir.
    static func resolved(from code: String?) -> PreferredTheme {
        // Gerekli data eksikse erken çıkış yapar.
        guard let code else {
            return .system
        }

        return PreferredTheme(rawValue: code) ?? .system
    }
}

// XPendoTheme, app genelinde kullanılan renk tokenlarını merkezi olarak tanımlar.
// Adaptive color kullanıldığı için light/dark mode renkleri aynı çağrı noktalarından yönetilir.
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

    // UIColor dynamic provider ile sistem light/dark değişimine göre Color üretilir.
    private static func adaptiveColor(light: UIColor, dark: UIColor) -> Color {
        Color(
            uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? dark : light
            }
        )
    }
}

// Hex string extension, category renklerinin SwiftData'da string saklanıp UI'da Color'a çevrilmesini sağlar.
extension Color {
    // Bu value’yu çalışmak için ihtiyaç duyduğu data ile hazırlar.
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

        // Gerekli data eksikse erken çıkış yapar.
        guard cleanedHex.count == 6, let hexValue = UInt(cleanedHex, radix: 16) else {
            return nil
        }

        self.init(hex: hexValue, alpha: alpha)
    }
}

// UIColor’ın ana declaration’ını değiştirmeden ilgili davranış ekler.
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
