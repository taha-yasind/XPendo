import Foundation
import UserNotifications

enum NotificationPermissionState {
    case notDetermined
    case authorized
    case denied

    var isAuthorized: Bool {
        self == .authorized
    }
}

struct NotificationScheduleContext {
    let notificationsEnabled: Bool
    let dailyReminderEnabled: Bool
    let budgetWarningEnabled: Bool
    let budgets: [Budget]
    let expenses: [Expense]
}

enum LocalNotificationManager {
    private static let notificationCenter = UNUserNotificationCenter.current()
    private static let dailyReminderIdentifier = "xpendo.daily.reminder"
    private static let budgetWarningIdentifier = "xpendo.budget.warning"

    static func permissionState() async -> NotificationPermissionState {
        let settings = await notificationCenter.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .denied
        }
    }

    static func requestAuthorization() async throws -> Bool {
        try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
    }

    static func refreshSchedules(using context: NotificationScheduleContext) async throws {
        let permissionState = await permissionState()

        guard context.notificationsEnabled, permissionState.isAuthorized else {
            removeAllRequests()
            return
        }

        if context.dailyReminderEnabled {
            try await scheduleDailyReminder()
        } else {
            removeDailyReminder()
        }

        if context.budgetWarningEnabled {
            try await scheduleBudgetWarningIfNeeded(using: context)
        } else {
            removeBudgetWarning()
        }
    }

    static func removeAllRequests() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: allIdentifiers)
    }

    private static func scheduleDailyReminder() async throws {
        let content = UNMutableNotificationContent()
        content.title = "Daily Expense Reminder"
        content.body = "Take a moment to record today's spending in Xpendo."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: dailyReminderIdentifier,
            content: content,
            trigger: trigger
        )

        notificationCenter.removePendingNotificationRequests(withIdentifiers: [dailyReminderIdentifier])
        try await notificationCenter.add(request)
    }

    private static func scheduleBudgetWarningIfNeeded(using context: NotificationScheduleContext) async throws {
        let overspentCategoryCount = currentMonthOverspentCategoryCount(
            budgets: context.budgets,
            expenses: context.expenses
        )

        guard overspentCategoryCount > 0 else {
            removeBudgetWarning()
            return
        }

        let content = UNMutableNotificationContent()
        content.title = overspentCategoryCount == 1 ? "Budget Warning" : "Budget Warnings"
        content.body = overspentCategoryCount == 1
            ? "One category is over its monthly limit. Review it in Xpendo."
            : "\(overspentCategoryCount) categories are over their monthly limits. Review them in Xpendo."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 18
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: budgetWarningIdentifier,
            content: content,
            trigger: trigger
        )

        notificationCenter.removePendingNotificationRequests(withIdentifiers: [budgetWarningIdentifier])
        try await notificationCenter.add(request)
    }

    private static func currentMonthOverspentCategoryCount(
        budgets: [Budget],
        expenses: [Expense],
        now: Date = .now
    ) -> Int {
        let calendar = Calendar.current
        let currentMonthBudgets = budgets.filter {
            $0.month == calendar.component(.month, from: now) &&
            $0.year == calendar.component(.year, from: now)
        }

        guard !currentMonthBudgets.isEmpty else {
            return 0
        }

        let monthExpenses = expenses.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
        let spentByCategoryID = Dictionary(grouping: monthExpenses, by: { $0.category.id })
            .mapValues { groupedExpenses in
                groupedExpenses.reduce(0) { partialResult, expense in
                    partialResult + expense.amount
                }
            }

        return currentMonthBudgets.filter { budget in
            (spentByCategoryID[budget.category.id] ?? 0) > budget.limitAmount
        }.count
    }

    private static func removeDailyReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [dailyReminderIdentifier])
    }

    private static func removeBudgetWarning() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [budgetWarningIdentifier])
    }

    private static var allIdentifiers: [String] {
        [dailyReminderIdentifier, budgetWarningIdentifier]
    }
}
