import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class SettingsViewModel {
    struct CurrencyOption: Identifiable, Hashable {
        let code: String
        let name: String

        var id: String { code }
        var displayTitle: String { "\(code) • \(name)" }
    }

    struct ThemeOption: Identifiable, Hashable {
        let theme: PreferredTheme

        var id: String { theme.rawValue }
        var code: String { theme.rawValue }
        var title: String { theme.displayName }
        var systemImage: String { theme.systemImage }
    }

    struct LanguageOption: Identifiable, Hashable {
        let language: AppLanguage

        var id: String { language.rawValue }
        var code: String { language.rawValue }
        var title: String { language.displayName }
    }

    struct UtilityMessage {
        enum Tone {
            case success
            case info
        }

        let text: String
        let tone: Tone
    }

    var currencyCode = CurrencyConverter.supportedCurrencyCode(from: Locale.current.currency?.identifier)
    var preferredThemeCode = PreferredTheme.system.rawValue
    var preferredLanguageCode = AppLanguage.resolved(from: nil).rawValue
    var utilityMessage: UtilityMessage?
    var errorMessage: String?
    var isUpdatingPreferences = false
    var isResettingData = false

    let currencyOptions: [CurrencyOption]
    let themeOptions: [ThemeOption]
    let languageOptions: [LanguageOption]

    init() {
        currencyOptions = Self.makeCurrencyOptions()
        themeOptions = Self.makeThemeOptions()
        languageOptions = Self.makeLanguageOptions()
    }

    func load(from settings: AppSettings?) {
        currencyCode = CurrencyConverter.supportedCurrencyCode(from: settings?.currencyCode)
        preferredThemeCode = PreferredTheme.resolved(from: settings?.preferredThemeCode).rawValue
        preferredLanguageCode = AppLanguage.resolved(from: settings?.preferredLanguageCode).rawValue
    }

    func updateDisplayPreferences(
        currencyCode newCurrencyCode: String,
        preferredThemeCode newThemeCode: String,
        preferredLanguageCode newLanguageCode: String,
        settings: AppSettings?,
        modelContext: ModelContext
    ) async {
        let resolvedCurrencyCode = CurrencyConverter.supportedCurrencyCode(from: newCurrencyCode)
        let resolvedThemeCode = PreferredTheme.resolved(from: newThemeCode).rawValue
        let resolvedLanguageCode = AppLanguage.resolved(from: newLanguageCode).rawValue

        guard let settings else {
            errorMessage = AppLocalization.string("error.preferencesUnavailable")
            return
        }

        let currentThemeCode = PreferredTheme.resolved(from: settings.preferredThemeCode).rawValue
        let currentLanguageCode = AppLanguage.resolved(from: settings.preferredLanguageCode).rawValue

        guard
            resolvedCurrencyCode != settings.currencyCode ||
                resolvedThemeCode != currentThemeCode ||
                resolvedLanguageCode != currentLanguageCode
        else {
            return
        }

        errorMessage = nil
        utilityMessage = nil
        isUpdatingPreferences = true
        defer { isUpdatingPreferences = false }

        let previousCurrencyCode = settings.currencyCode
        let previousThemeCode = settings.preferredThemeCode
        let previousLanguageCode = settings.preferredLanguageCode

        settings.currencyCode = resolvedCurrencyCode
        settings.preferredThemeCode = resolvedThemeCode
        settings.preferredLanguageCode = resolvedLanguageCode
        currencyCode = resolvedCurrencyCode
        preferredThemeCode = resolvedThemeCode
        preferredLanguageCode = resolvedLanguageCode
        AppLocalization.updateLanguage(code: resolvedLanguageCode)

        do {
            try modelContext.save()
        } catch {
            settings.currencyCode = previousCurrencyCode
            settings.preferredThemeCode = previousThemeCode
            settings.preferredLanguageCode = previousLanguageCode
            currencyCode = previousCurrencyCode
            preferredThemeCode = PreferredTheme.resolved(from: previousThemeCode).rawValue
            preferredLanguageCode = AppLanguage.resolved(from: previousLanguageCode).rawValue
            AppLocalization.updateLanguage(code: preferredLanguageCode)
            errorMessage = error.localizedDescription
        }
    }

    func clearRecordedData(modelContext: ModelContext) async {
        errorMessage = nil
        utilityMessage = nil
        isResettingData = true
        defer { isResettingData = false }

        do {
            let expenses = try modelContext.fetch(FetchDescriptor<Expense>())
            let budgets = try modelContext.fetch(FetchDescriptor<Budget>())

            guard !expenses.isEmpty || !budgets.isEmpty else {
                utilityMessage = UtilityMessage(
                    text: AppLocalization.string("settings.utility.nothingToClear"),
                    tone: .info
                )
                return
            }

            for expense in expenses {
                modelContext.delete(expense)
            }

            for budget in budgets {
                modelContext.delete(budget)
            }

            try modelContext.save()
            try await NotificationSyncService.refresh(using: modelContext)

            utilityMessage = UtilityMessage(
                text: AppLocalization.string("settings.utility.dataCleared"),
                tone: .success
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var selectedCurrencyName: String {
        currencyName(for: currencyCode)
    }

    var selectedThemeName: String {
        themeName(for: preferredThemeCode)
    }

    var selectedLanguageName: String {
        languageName(for: preferredLanguageCode)
    }

    var versionValue: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }

    var isBusy: Bool {
        isUpdatingPreferences || isResettingData
    }

    func currencyName(for code: String) -> String {
        currencyOptions.first(where: { $0.code == code })?.name
            ?? Locale.current.localizedString(forCurrencyCode: code)
            ?? code
    }

    func themeName(for code: String) -> String {
        PreferredTheme.resolved(from: code).displayName
    }

    func languageName(for code: String) -> String {
        AppLanguage.resolved(from: code).displayName
    }

    private static func makeCurrencyOptions() -> [CurrencyOption] {
        AppCurrency.allCases.map { currency in
            CurrencyOption(code: currency.rawValue, name: currency.displayName)
        }
    }

    private static func makeThemeOptions() -> [ThemeOption] {
        PreferredTheme.allCases.map { theme in
            ThemeOption(theme: theme)
        }
    }

    private static func makeLanguageOptions() -> [LanguageOption] {
        AppLanguage.allCases.map { language in
            LanguageOption(language: language)
        }
    }
}
