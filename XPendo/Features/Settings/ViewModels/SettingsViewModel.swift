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

    struct UtilityMessage {
        enum Tone {
            case success
            case info
        }

        let text: String
        let tone: Tone
    }

    var currencyCode = CurrencyConverter.supportedCurrencyCode(from: Locale.current.currency?.identifier)
    var preferredThemeCode = PreferredTheme.light.rawValue
    var utilityMessage: UtilityMessage?
    var errorMessage: String?
    var isUpdatingPreferences = false
    var isResettingData = false

    let currencyOptions: [CurrencyOption]
    let themeOptions: [ThemeOption]

    init() {
        currencyOptions = Self.makeCurrencyOptions()
        themeOptions = Self.makeThemeOptions()
    }

    func load(from settings: AppSettings?) {
        currencyCode = CurrencyConverter.supportedCurrencyCode(from: settings?.currencyCode)
        preferredThemeCode = PreferredTheme.resolved(from: settings?.preferredThemeCode).rawValue
    }

    func updateDisplayPreferences(
        currencyCode newCurrencyCode: String,
        preferredThemeCode newThemeCode: String,
        settings: AppSettings?,
        modelContext: ModelContext
    ) async {
        let resolvedCurrencyCode = CurrencyConverter.supportedCurrencyCode(from: newCurrencyCode)
        let resolvedThemeCode = PreferredTheme.resolved(from: newThemeCode).rawValue

        guard let settings else {
            errorMessage = "App preferences are currently unavailable."
            return
        }

        let currentThemeCode = PreferredTheme.resolved(from: settings.preferredThemeCode).rawValue

        guard resolvedCurrencyCode != settings.currencyCode || resolvedThemeCode != currentThemeCode else {
            return
        }

        errorMessage = nil
        utilityMessage = nil
        isUpdatingPreferences = true
        defer { isUpdatingPreferences = false }

        let previousCurrencyCode = settings.currencyCode
        let previousThemeCode = settings.preferredThemeCode

        settings.currencyCode = resolvedCurrencyCode
        settings.preferredThemeCode = resolvedThemeCode
        currencyCode = resolvedCurrencyCode
        preferredThemeCode = resolvedThemeCode

        do {
            try modelContext.save()
        } catch {
            settings.currencyCode = previousCurrencyCode
            settings.preferredThemeCode = previousThemeCode
            currencyCode = previousCurrencyCode
            preferredThemeCode = PreferredTheme.resolved(from: previousThemeCode).rawValue
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
                    text: "There is no recorded expense or budget data to clear right now.",
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
                text: "All saved expenses and budget entries were removed. Categories and preferences were kept.",
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
}
