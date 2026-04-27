import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case turkish = "tr"

    var id: String { rawValue }

    var locale: Locale {
        Locale(identifier: rawValue)
    }

    var displayName: String {
        switch self {
        case .english:
            return AppLocalization.string("language.english")
        case .turkish:
            return AppLocalization.string("language.turkish")
        }
    }

    static func resolved(from code: String?) -> AppLanguage {
        guard let code else {
            let preferredCode = Locale.current.language.languageCode?.identifier ?? AppLanguage.english.rawValue
            return AppLanguage(rawValue: preferredCode) ?? .english
        }

        return AppLanguage(rawValue: code) ?? .english
    }
}

enum AppLocalization {
    private static let userDefaultsKey = "xpendo.preferredLanguageCode"

    static var currentLanguageCode: String = {
        UserDefaults.standard.string(forKey: userDefaultsKey)
            ?? AppLanguage.resolved(from: nil).rawValue
    }()

    static func updateLanguage(code: String) {
        let resolved = AppLanguage.resolved(from: code).rawValue
        currentLanguageCode = resolved
        UserDefaults.standard.set(resolved, forKey: userDefaultsKey)
    }

    static var locale: Locale {
        AppLanguage.resolved(from: currentLanguageCode).locale
    }

    static func string(_ key: String) -> String {
        let resolvedLanguageCode = AppLanguage.resolved(from: currentLanguageCode).rawValue
        let localizedBundle = bundle(for: resolvedLanguageCode)
        let localizedValue = localizedBundle.localizedString(forKey: key, value: nil, table: nil)

        guard localizedValue == key, localizedBundle != .main else {
            return localizedValue
        }

        return Bundle.main.localizedString(forKey: key, value: nil, table: nil)
    }

    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: string(key), locale: locale, arguments: arguments)
    }

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
