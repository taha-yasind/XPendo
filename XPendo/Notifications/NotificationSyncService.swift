import Foundation
import SwiftData

@MainActor
enum NotificationSyncService {
    static func refresh(using modelContext: ModelContext) async throws {
        guard let settings = try modelContext.fetch(FetchDescriptor<AppSettings>()).first else {
            LocalNotificationManager.removeAllRequests()
            return
        }

        let budgets = try modelContext.fetch(FetchDescriptor<Budget>())
        let expenses = try modelContext.fetch(FetchDescriptor<Expense>())

        let context = NotificationScheduleContext(
            notificationsEnabled: settings.notificationsEnabled,
            dailyReminderEnabled: settings.dailyReminderEnabled,
            budgetWarningEnabled: settings.budgetWarningEnabled,
            budgets: budgets,
            expenses: expenses
        )

        try await LocalNotificationManager.refreshSchedules(using: context)
    }
}
