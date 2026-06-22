import Foundation
import Observation
import SwiftData

// NotificationSettingsViewModel, permission state ve reminder tercihlerini yönetir.
// LocalNotificationManager ile konuşur, AppSettings'e kaydeder ve schedule refresh tetikler.
@MainActor
@Observable
final class NotificationSettingsViewModel {
    var notificationsEnabled = false
    var dailyReminderEnabled = false
    var budgetWarningEnabled = false
    var permissionState: NotificationPermissionState = .notDetermined
    var infoMessage: String?
    var errorMessage: String?
    var isProcessing = false

    // Settings ekranı açıldığında mevcut AppSettings ve sistem permission durumu okunur.
    func load(from settings: AppSettings?) async {
        guard let settings else {
            return
        }

        notificationsEnabled = settings.notificationsEnabled
        dailyReminderEnabled = settings.dailyReminderEnabled
        budgetWarningEnabled = settings.budgetWarningEnabled
        permissionState = await LocalNotificationManager.permissionState()
        infoMessage = permissionState == .denied
            ? AppLocalization.string("settings.notifications.permission.denied.long")
            : nil
    }

    // Ana notification toggle'ı permission isteyebilir; izin yoksa reminder seçenekleri kapalı kalır.
    func setNotificationsEnabled(
        _ isEnabled: Bool,
        settings: AppSettings?,
        modelContext: ModelContext
    ) async {
        guard let settings else {
            notificationsEnabled = false
            return
        }

        errorMessage = nil
        let previousValue = settings.notificationsEnabled
        isProcessing = true
        defer { isProcessing = false }

        if isEnabled {
            permissionState = await LocalNotificationManager.permissionState()

            switch permissionState {
            case .authorized:
                settings.notificationsEnabled = true
                notificationsEnabled = true
                infoMessage = nil

            case .notDetermined:
                do {
                    let granted = try await LocalNotificationManager.requestAuthorization()
                    permissionState = await LocalNotificationManager.permissionState()
                    settings.notificationsEnabled = granted
                    notificationsEnabled = granted
                    infoMessage = granted ? nil : AppLocalization.string("settings.notifications.permission.notGranted")
                } catch {
                    notificationsEnabled = false
                    settings.notificationsEnabled = false
                    errorMessage = error.localizedDescription
                }

            case .denied:
                notificationsEnabled = false
                settings.notificationsEnabled = false
                infoMessage = AppLocalization.string("settings.notifications.permission.denied.short")
            }
        } else {
            settings.notificationsEnabled = false
            notificationsEnabled = false
            infoMessage = permissionState == .denied
                ? AppLocalization.string("settings.notifications.permission.denied.short")
                : nil
        }

        do {
            try modelContext.save()
            try await NotificationSyncService.refresh(using: modelContext)
        } catch {
            settings.notificationsEnabled = previousValue
            notificationsEnabled = previousValue
            errorMessage = error.localizedDescription
        }
    }

    func setDailyReminderEnabled(
        _ isEnabled: Bool,
        settings: AppSettings?,
        modelContext: ModelContext
    ) async {
        await updatePreference(
            isEnabled,
            currentValue: settings?.dailyReminderEnabled ?? false,
            settings: settings,
            modelContext: modelContext
        ) { settings, newValue in
            settings.dailyReminderEnabled = newValue
            self.dailyReminderEnabled = newValue
        } onRollback: { previousValue in
            self.dailyReminderEnabled = previousValue
        }
    }

    func setBudgetWarningEnabled(
        _ isEnabled: Bool,
        settings: AppSettings?,
        modelContext: ModelContext
    ) async {
        await updatePreference(
            isEnabled,
            currentValue: settings?.budgetWarningEnabled ?? false,
            settings: settings,
            modelContext: modelContext
        ) { settings, newValue in
            settings.budgetWarningEnabled = newValue
            self.budgetWarningEnabled = newValue
        } onRollback: { previousValue in
            self.budgetWarningEnabled = previousValue
        }
    }

    // Apply butonu tüm notification draft tercihlerini tek transaction gibi uygular.
    func applyChanges(
        notificationsEnabled requestedNotificationsEnabled: Bool,
        dailyReminderEnabled requestedDailyReminderEnabled: Bool,
        budgetWarningEnabled requestedBudgetWarningEnabled: Bool,
        settings: AppSettings?,
        modelContext: ModelContext
    ) async {
        guard let settings else {
            errorMessage = AppLocalization.string("error.preferencesUnavailable")
            return
        }

        errorMessage = nil
        isProcessing = true
        defer { isProcessing = false }

        let previousNotificationsEnabled = settings.notificationsEnabled
        let previousDailyReminderEnabled = settings.dailyReminderEnabled
        let previousBudgetWarningEnabled = settings.budgetWarningEnabled

        permissionState = await LocalNotificationManager.permissionState()

        // Bildirimler isteniyorsa önce sistem permission sonucu çözülür.
        var resolvedNotificationsEnabled = false
        var infoMessage: String?

        if requestedNotificationsEnabled {
            switch permissionState {
            case .authorized:
                resolvedNotificationsEnabled = true

            case .notDetermined:
                do {
                    let granted = try await LocalNotificationManager.requestAuthorization()
                    permissionState = await LocalNotificationManager.permissionState()
                    resolvedNotificationsEnabled = granted
                    infoMessage = granted ? nil : AppLocalization.string("settings.notifications.permission.notGranted")
                } catch {
                    errorMessage = error.localizedDescription
                    restoreState(
                        notificationsEnabled: previousNotificationsEnabled,
                        dailyReminderEnabled: previousDailyReminderEnabled,
                        budgetWarningEnabled: previousBudgetWarningEnabled,
                        settings: settings
                    )
                    return
                }

            case .denied:
                resolvedNotificationsEnabled = false
                infoMessage = AppLocalization.string("settings.notifications.permission.denied.short")
            }
        } else if permissionState == .denied {
            infoMessage = AppLocalization.string("settings.notifications.permission.denied.short")
        }

        let resolvedDailyReminderEnabled = resolvedNotificationsEnabled ? requestedDailyReminderEnabled : false
        let resolvedBudgetWarningEnabled = resolvedNotificationsEnabled ? requestedBudgetWarningEnabled : false

        // Ana izin kapalıysa alt reminder ayarları da kapalı kaydedilir.
        settings.notificationsEnabled = resolvedNotificationsEnabled
        settings.dailyReminderEnabled = resolvedDailyReminderEnabled
        settings.budgetWarningEnabled = resolvedBudgetWarningEnabled

        notificationsEnabled = resolvedNotificationsEnabled
        dailyReminderEnabled = resolvedDailyReminderEnabled
        budgetWarningEnabled = resolvedBudgetWarningEnabled
        self.infoMessage = infoMessage

        do {
            try modelContext.save()
            try await NotificationSyncService.refresh(using: modelContext)
        } catch {
            restoreState(
                notificationsEnabled: previousNotificationsEnabled,
                dailyReminderEnabled: previousDailyReminderEnabled,
                budgetWarningEnabled: previousBudgetWarningEnabled,
                settings: settings
            )
            errorMessage = error.localizedDescription
        }
    }

    var permissionStatusTitle: String {
        switch permissionState {
        case .authorized:
            return AppLocalization.string("settings.notifications.status.authorized")
        case .notDetermined:
            return AppLocalization.string("settings.notifications.status.notRequested")
        case .denied:
            return AppLocalization.string("settings.notifications.status.denied")
        }
    }

    var permissionStatusDescription: String {
        switch permissionState {
        case .authorized:
            return AppLocalization.string("settings.notifications.description.authorized")
        case .notDetermined:
            return AppLocalization.string("settings.notifications.description.notRequested")
        case .denied:
            return AppLocalization.string("settings.notifications.description.denied")
        }
    }

    var reminderControlsDisabled: Bool {
        !notificationsEnabled || !permissionState.isAuthorized || isProcessing
    }

    // Tekil reminder değişikliklerinde ortak save/rollback davranışı bu helper ile paylaşılır.
    private func updatePreference(
        _ isEnabled: Bool,
        currentValue: Bool,
        settings: AppSettings?,
        modelContext: ModelContext,
        apply: @escaping (AppSettings, Bool) -> Void,
        onRollback: @escaping (Bool) -> Void
    ) async {
        guard let settings else {
            return
        }

        errorMessage = nil
        isProcessing = true
        defer { isProcessing = false }

        apply(settings, isEnabled)

        do {
            try modelContext.save()
            try await NotificationSyncService.refresh(using: modelContext)
        } catch {
            apply(settings, currentValue)
            onRollback(currentValue)
            errorMessage = error.localizedDescription
        }
    }

    private func restoreState(
        notificationsEnabled: Bool,
        dailyReminderEnabled: Bool,
        budgetWarningEnabled: Bool,
        settings: AppSettings
    ) {
        settings.notificationsEnabled = notificationsEnabled
        settings.dailyReminderEnabled = dailyReminderEnabled
        settings.budgetWarningEnabled = budgetWarningEnabled

        self.notificationsEnabled = notificationsEnabled
        self.dailyReminderEnabled = dailyReminderEnabled
        self.budgetWarningEnabled = budgetWarningEnabled
    }
}
