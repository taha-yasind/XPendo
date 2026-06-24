/*
 DOSYA: LocalNotificationManager.swift
 AMAÇ: Local notification permission request ve scheduling işlemlerini sarar. UserNotifications detaylarını async-friendly methodların arkasında gizler.
 KULLANAN: NotificationSettingsViewModel ve NotificationSyncService tarafından kullanılır.
*/
import Foundation
import UserNotifications

// NotificationPermissionState, sistem notification permission durumunu app içinde sade bir enum olarak temsil eder.
enum NotificationPermissionState {
    case notDetermined
    case authorized
    case denied

    // Bu type için odaklı bir davranış parçasını yönetir.
    var isAuthorized: Bool {
        self == .authorized
    }
}

// NotificationScheduleContext, notification planlama için gerekli settings ve güncel finans verisini taşır.
struct NotificationScheduleContext {
    let notificationsEnabled: Bool
    let dailyReminderEnabled: Bool
    let budgetWarningEnabled: Bool
    let budgets: [Budget]
    let expenses: [Expense]
}

// LocalNotificationManager, UserNotifications framework ile local reminder planlama sorumluluğunu üstlenir.
// Settings ViewModel yalnızca tercihleri kaydeder; gerçek schedule işlemleri burada yapılır.
enum LocalNotificationManager {
    private static let notificationCenter = UNUserNotificationCenter.current()
    private static let dailyReminderIdentifier = "xpendo.daily.reminder"
    private static let budgetWarningIdentifier = "xpendo.budget.warning"

    // Sistem permission durumunu okunabilir app enum'una çevirir.
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

    // System’den permission veya updated status ister.
    static func requestAuthorization() async throws -> Bool {
        // Async operation tamamlanana kadar bekler.
        try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
    }

    // Güncel settings'e göre daily reminder ve budget warning requestleri yeniden kurulur veya kaldırılır.
    static func refreshSchedules(using context: NotificationScheduleContext) async throws {
        let permissionState = await permissionState()

        // Gerekli data eksikse erken çıkış yapar.
        guard context.notificationsEnabled, permissionState.isAuthorized else {
            // Ana izin veya app tercihi kapalıysa bekleyen XPendo notification requestleri temizlenir.
            removeAllRequests()
            return
        }

        if context.dailyReminderEnabled {
            // Async operation tamamlanana kadar bekler.
            try await scheduleDailyReminder()
        } else {
            removeDailyReminder()
        }

        if context.budgetWarningEnabled {
            // Async operation tamamlanana kadar bekler.
            try await scheduleBudgetWarningIfNeeded(using: context)
        } else {
            removeBudgetWarning()
        }
    }

    // User action’ı onayladıktan sonra saved datayı siler.
    static func removeAllRequests() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: allIdentifiers)
    }

    // Her gün 20:00'de expense kaydetmeyi hatırlatan local notification planlanır.
    private static func scheduleDailyReminder() async throws {
        let content = UNMutableNotificationContent()
        content.title = AppLocalization.string("notification.daily.title")
        content.body = AppLocalization.string("notification.daily.body")
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
        // Async operation tamamlanana kadar bekler.
        try await notificationCenter.add(request)
    }

    // Budget warning sadece mevcut ayda aşım varsa planlanır; aşım yoksa request kaldırılır.
    private static func scheduleBudgetWarningIfNeeded(using context: NotificationScheduleContext) async throws {
        let overspentCategoryCount = currentMonthOverspentCategoryCount(
            budgets: context.budgets,
            expenses: context.expenses
        )

        // Gerekli data eksikse erken çıkış yapar.
        guard overspentCategoryCount > 0 else {
            removeBudgetWarning()
            return
        }

        let content = UNMutableNotificationContent()
        content.title = overspentCategoryCount == 1
            ? AppLocalization.string("notification.budget.single.title")
            : AppLocalization.string("notification.budget.multiple.title")
        content.body = overspentCategoryCount == 1
            ? AppLocalization.string("notification.budget.single.body")
            : AppLocalization.format("notification.budget.multiple.body", overspentCategoryCount)
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
        // Async operation tamamlanana kadar bekler.
        try await notificationCenter.add(request)
    }

    // Current month budget aşımı, Budget limitleri ile aynı ay Expense toplamları karşılaştırılarak hesaplanır.
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

        // Gerekli data eksikse erken çıkış yapar.
        guard !currentMonthBudgets.isEmpty else {
            return 0
        }

        let monthExpenses = expenses.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
        let spentByCategoryID = Dictionary(grouping: monthExpenses, by: { $0.categoryID })
            .mapValues { groupedExpenses in
                groupedExpenses.reduce(0) { partialResult, expense in
                    partialResult + expense.amount
                }
            }

        return currentMonthBudgets.filter { budget in
            // Gerekli data eksikse erken çıkış yapar.
            guard let categoryID = budget.categoryID else {
                return false
            }

            return (spentByCategoryID[Optional(categoryID)] ?? 0) > budget.limitAmount
        }.count
    }

    // User action’ı onayladıktan sonra saved datayı siler.
    private static func removeDailyReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [dailyReminderIdentifier])
    }

    // User action’ı onayladıktan sonra saved datayı siler.
    private static func removeBudgetWarning() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [budgetWarningIdentifier])
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private static var allIdentifiers: [String] {
        [dailyReminderIdentifier, budgetWarningIdentifier]
    }
}
