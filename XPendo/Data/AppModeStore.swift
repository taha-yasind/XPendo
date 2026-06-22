import Foundation

// AppDataMode, standard kullanıcı verisi ile demo data store ayrımını temsil eder.
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

// AppModeStore, demo mode tercihini UserDefaults üzerinde saklayan küçük helper yapıdır.
// XPendoApp bu değere göre hangi SwiftData ModelContainer'ın kullanılacağını seçer.
enum AppModeStore {
    static let key = "xpendo.demoModeEnabled"

    static var isDemoModeEnabled: Bool {
        UserDefaults.standard.bool(forKey: key)
    }

    static func setDemoModeEnabled(_ isEnabled: Bool) {
        UserDefaults.standard.set(isEnabled, forKey: key)
    }
}
