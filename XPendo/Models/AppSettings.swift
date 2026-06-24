/*
 DOSYA: AppSettings.swift
 AMAÇ: SwiftData içinde persist edilen app-wide preference modelini tanımlar. Bu settings onboarding, currency, language ve notification davranışını kontrol eder.
 KULLANAN: SettingsViewModel, NotificationSettingsViewModel, AppDataSeeder ve AppRootView tarafından kullanılır.
*/
import Foundation
import SwiftData

// AppSettings, uygulama genelindeki kullanıcı tercihlerini SwiftData içinde saklar.
// Currency, theme, language ve notification tercihleri AppRootView ile Settings akışını etkiler.
@Model
// Shared app behavior veya persisted data sahibi olan reference type tanımlar.
final class AppSettings {
    var id: UUID = UUID()
    var currencyCode: String = "USD"
    var preferredThemeCode: String?
    var preferredLanguageCode: String?
    var notificationsEnabled: Bool = false
    var dailyReminderEnabled: Bool = false
    var budgetWarningEnabled: Bool = false

    // Bu value’yu çalışmak için ihtiyaç duyduğu data ile hazırlar.
    init(
        id: UUID = UUID(),
        currencyCode: String,
        preferredThemeCode: String = PreferredTheme.system.rawValue,
        preferredLanguageCode: String? = nil,
        notificationsEnabled: Bool = false,
        dailyReminderEnabled: Bool = false,
        budgetWarningEnabled: Bool = false
    ) {
        self.id = id
        self.currencyCode = currencyCode
        self.preferredThemeCode = preferredThemeCode
        self.preferredLanguageCode = preferredLanguageCode
        self.notificationsEnabled = notificationsEnabled
        self.dailyReminderEnabled = dailyReminderEnabled
        self.budgetWarningEnabled = budgetWarningEnabled
    }
}
