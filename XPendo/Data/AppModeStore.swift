import Foundation

enum AppDataMode {
    case standard
    case demo

    var configurationName: String {
        switch self {
        case .standard:
            return "XPendoStandardStore"
        case .demo:
            return "XPendoDemoStore"
        }
    }
}

enum AppModeStore {
    static let key = "xpendo.demoModeEnabled"

    static var isDemoModeEnabled: Bool {
        UserDefaults.standard.bool(forKey: key)
    }

    static func setDemoModeEnabled(_ isEnabled: Bool) {
        UserDefaults.standard.set(isEnabled, forKey: key)
    }
}
