import Foundation
import SwiftData

// NotificationSyncService, SwiftData kayıtları ile LocalNotificationManager arasında köprü görevi görür.
// Expense veya Budget değiştiğinde çağrılarak schedule context'i güncel veriden yeniden oluşturur.
@MainActor
enum NotificationSyncService {
    // AppSettings yoksa notification requestleri temizlenir; varsa budget ve expense verileriyle refresh yapılır.
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
