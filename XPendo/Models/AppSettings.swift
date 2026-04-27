import Foundation
import SwiftData

@Model
final class AppSettings {
    @Attribute(.unique) var id: UUID
    var currencyCode: String
    var preferredThemeCode: String?
    var preferredLanguageCode: String?
    var notificationsEnabled: Bool
    var dailyReminderEnabled: Bool
    var budgetWarningEnabled: Bool

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
