/*
 DOSYA: AppModeStore.swift
 AMAÇ: App’in normal mode veya demo mode ile çalıştığını saklar. Birden fazla ekranın seçili data mode’a tutarlı tepki vermesini sağlar.
 KULLANAN: AppRootView, SettingsViewModel ve demo data değiştirmesi gereken viewler tarafından kullanılır.
*/
import Foundation

// AppDataMode, standard kullanıcı verisi ile demo data store ayrımını temsil eder.
enum AppDataMode {
    case standard
    case demo

    // Bu type için odaklı bir davranış parçasını yönetir.
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

    // Bu type için odaklı bir davranış parçasını yönetir.
    static var isDemoModeEnabled: Bool {
        UserDefaults.standard.bool(forKey: key)
    }

    // User setting veya state değişikliğini uygular.
    static func setDemoModeEnabled(_ isEnabled: Bool) {
        UserDefaults.standard.set(isEnabled, forKey: key)
    }
}
