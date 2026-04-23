import Foundation
import SwiftData

@Model
final class AppSettings {
    @Attribute(.unique) var id: UUID
    var currencyCode: String
    var notificationsEnabled: Bool
    var dailyReminderEnabled: Bool
    var budgetWarningEnabled: Bool

    init(
        id: UUID = UUID(),
        currencyCode: String,
        notificationsEnabled: Bool = false,
        dailyReminderEnabled: Bool = false,
        budgetWarningEnabled: Bool = false
    ) {
        self.id = id
        self.currencyCode = currencyCode
        self.notificationsEnabled = notificationsEnabled
        self.dailyReminderEnabled = dailyReminderEnabled
        self.budgetWarningEnabled = budgetWarningEnabled
    }
}
