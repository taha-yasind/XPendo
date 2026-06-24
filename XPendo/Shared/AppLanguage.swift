/*
 DOSYA: AppLanguage.swift
 AMAÇ: Desteklenen app language seçeneklerini ve display label değerlerini listeler. Settings ve localization koduna shared language type sağlar.
 KULLANAN: SettingsViewModel, SettingsView ve localized text helperları tarafından kullanılır.
*/
import Foundation

// AppLanguage, desteklenen localization dillerini ve ilgili Locale bilgisini temsil eder.
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case turkish = "tr"

    var id: String { rawValue }

    // Bu type için odaklı bir davranış parçasını yönetir.
    var locale: Locale {
        Locale(identifier: rawValue)
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    var displayName: String {
        switch self {
        case .english:
            return AppLocalization.string("language.english")
        case .turkish:
            return AppLocalization.string("language.turkish")
        }
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    static func resolved(from code: String?) -> AppLanguage {
        // Gerekli data eksikse erken çıkış yapar.
        guard let code else {
            let preferredCode = Locale.current.language.languageCode?.identifier ?? AppLanguage.english.rawValue
            return AppLanguage(rawValue: preferredCode) ?? .english
        }

        return AppLanguage(rawValue: code) ?? .english
    }
}

// AppLocalization, seçili dili UserDefaults'ta tutar ve string lookup işlemini tek helper'da toplar.
// Settings dil değiştirince AppRootView locale ve View identity üzerinden UI'yı yeniler.
enum AppLocalization {
    private static let userDefaultsKey = "xpendo.preferredLanguageCode"

    static var currentLanguageCode: String = {
        UserDefaults.standard.string(forKey: userDefaultsKey)
            ?? AppLanguage.resolved(from: nil).rawValue
    }()

    // Dil tercihi güncellenir ve sonraki localization lookup'ları bu code'u kullanır.
    static func updateLanguage(code: String) {
        let resolved = AppLanguage.resolved(from: code).rawValue
        currentLanguageCode = resolved
        UserDefaults.standard.set(resolved, forKey: userDefaultsKey)
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    static var locale: Locale {
        AppLanguage.resolved(from: currentLanguageCode).locale
    }

    // Önce seçili dil bundle'ı denenir; key bulunamazsa main bundle fallback olur.
    static func string(_ key: String) -> String {
        let resolvedLanguageCode = AppLanguage.resolved(from: currentLanguageCode).rawValue
        let localizedBundle = bundle(for: resolvedLanguageCode)

        // Sentinel ile key-not-found durumu doğru tespit edilir.
        // Boş string key olarak kullanılamaz, bu yüzden güvenli sentinel'dır.
        let sentinel = "___xpendo_missing___"
        let localizedValue = localizedBundle.localizedString(forKey: key, value: sentinel, table: nil)

        // Key dil bundle'ında bulundu; direkt döndür (değer key ile aynı olsa bile).
        if localizedValue != sentinel {
            return localizedValue
        }

        // Key bulunamadı; main bundle'a fallback yap (sonsuz döngüden kaçınmak için kontrol).
        guard localizedBundle !== Bundle.main else {
            return key
        }
        return Bundle.main.localizedString(forKey: key, value: key, table: nil)
    }

    // Raw value değerlerini interface’te gösterim için formatlar.
    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: string(key), locale: locale, arguments: arguments)
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private static func bundle(for languageCode: String) -> Bundle {
        guard
            let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return .main
        }

        return bundle
    }
}
