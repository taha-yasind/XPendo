import Foundation
import Observation
import SwiftData

// SettingsViewModel, currency, theme, language, demo data ve data reset işlemlerini yönetir.
// UI draft değerleri bu ViewModel üzerinden AppSettings modeline güvenli şekilde kaydedilir.
@MainActor
@Observable
final class SettingsViewModel {
    // CurrencyOption, Settings menüsünde gösterilecek desteklenen para birimi bilgisidir.
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

    // UtilityMessage, reset/demo işlemlerinden sonra kullanıcıya gösterilecek kısa feedback bilgisidir.
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
    var isProcessingDemoData = false
    var isDemoModeEnabled = AppModeStore.isDemoModeEnabled

    let currencyOptions: [CurrencyOption]
    let themeOptions: [ThemeOption]
    let languageOptions: [LanguageOption]

    init() {
        currencyOptions = Self.makeCurrencyOptions()
        themeOptions = Self.makeThemeOptions()
        languageOptions = Self.makeLanguageOptions()
    }

    // SwiftData'daki AppSettings kaydı okunarak ekrandaki mevcut preference state'i hazırlanır.
    func load(from settings: AppSettings?) {
        currencyCode = CurrencyConverter.supportedCurrencyCode(from: settings?.currencyCode)
        preferredThemeCode = PreferredTheme.resolved(from: settings?.preferredThemeCode).rawValue
        preferredLanguageCode = AppLanguage.resolved(from: settings?.preferredLanguageCode).rawValue
    }

    // Theme, language ve currency değişiklikleri tek apply aksiyonuyla AppSettings'e kaydedilir.
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

        // Önce model ve ViewModel state güncellenir; save hata verirse aşağıda eski değerlere dönülür.
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

    // Kullanıcının kayıtlı Expense ve Budget verilerini temizler; AppSettings ve default category kayıtları korunur.
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

    // Demo mode tercihi UserDefaults'a yazılır; app launch sırasında ilgili ModelContainer seçilir.
    func setDemoModeEnabled(_ isEnabled: Bool) {
        isDemoModeEnabled = isEnabled
        AppModeStore.setDemoModeEnabled(isEnabled)
    }

    // Demo data yalnızca uygun durumda yüklenir ve ardından notification schedule güncellenir.
    func loadDemoData(modelContext: ModelContext) async {
        errorMessage = nil
        utilityMessage = nil
        isProcessingDemoData = true
        defer { isProcessingDemoData = false }

        do {
            let result = try DemoDataSeeder.loadDemoData(in: modelContext)
            setDemoModeEnabled(true)
            try await NotificationSyncService.refresh(using: modelContext)

            utilityMessage = UtilityMessage(
                text: AppLocalization.format(
                    "settings.demo.message.loaded",
                    result.expenseCount,
                    result.budgetCount
                ),
                tone: .success
            )
        } catch let error as DemoDataSeeder.DemoDataError {
            switch error {
            case .existingData:
                utilityMessage = UtilityMessage(
                    text: AppLocalization.string("settings.demo.message.requiresEmptyState"),
                    tone: .info
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Demo data temizleme işlemi Settings üzerinden kullanıcıya feedback mesajı üretir.
    func clearDemoData(modelContext: ModelContext) async {
        errorMessage = nil
        utilityMessage = nil
        isProcessingDemoData = true
        defer { isProcessingDemoData = false }

        do {
            let result = try DemoDataSeeder.clearDemoData(in: modelContext)
            try await NotificationSyncService.refresh(using: modelContext)

            if result.expenseCount == 0 && result.budgetCount == 0 {
                utilityMessage = UtilityMessage(
                    text: AppLocalization.string("settings.demo.message.noDemoData"),
                    tone: .info
                )
            } else {
                utilityMessage = UtilityMessage(
                    text: AppLocalization.format(
                        "settings.demo.message.cleared",
                        result.expenseCount,
                        result.budgetCount
                    ),
                    tone: .success
                )
            }
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
        isUpdatingPreferences || isResettingData || isProcessingDemoData
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
