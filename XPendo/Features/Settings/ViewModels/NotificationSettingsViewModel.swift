import Foundation
import Observation
import SwiftData

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

    func load(from settings: AppSettings?) async {
        guard let settings else {
            return
        }

        notificationsEnabled = settings.notificationsEnabled
        dailyReminderEnabled = settings.dailyReminderEnabled
        budgetWarningEnabled = settings.budgetWarningEnabled
        permissionState = await LocalNotificationManager.permissionState()
        infoMessage = permissionState == .denied
            ? "Notification permission is denied in system settings. Xpendo cannot deliver reminders until it is re-enabled."
            : nil
    }

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
                    infoMessage = granted ? nil : "Notification permission was not granted."
                } catch {
                    notificationsEnabled = false
                    settings.notificationsEnabled = false
                    errorMessage = error.localizedDescription
                }

            case .denied:
                notificationsEnabled = false
                settings.notificationsEnabled = false
                infoMessage = "Notification permission is denied in system settings."
            }
        } else {
            settings.notificationsEnabled = false
            notificationsEnabled = false
            infoMessage = permissionState == .denied
                ? "Notification permission is denied in system settings."
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

    func applyChanges(
        notificationsEnabled requestedNotificationsEnabled: Bool,
        dailyReminderEnabled requestedDailyReminderEnabled: Bool,
        budgetWarningEnabled requestedBudgetWarningEnabled: Bool,
        settings: AppSettings?,
        modelContext: ModelContext
    ) async {
        guard let settings else {
            errorMessage = "App preferences are currently unavailable."
            return
        }

        errorMessage = nil
        isProcessing = true
        defer { isProcessing = false }

        let previousNotificationsEnabled = settings.notificationsEnabled
        let previousDailyReminderEnabled = settings.dailyReminderEnabled
        let previousBudgetWarningEnabled = settings.budgetWarningEnabled

        permissionState = await LocalNotificationManager.permissionState()

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
                    infoMessage = granted ? nil : "Notification permission was not granted."
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
                infoMessage = "Notification permission is denied in system settings."
            }
        } else if permissionState == .denied {
            infoMessage = "Notification permission is denied in system settings."
        }

        let resolvedDailyReminderEnabled = resolvedNotificationsEnabled ? requestedDailyReminderEnabled : false
        let resolvedBudgetWarningEnabled = resolvedNotificationsEnabled ? requestedBudgetWarningEnabled : false

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
            return "Authorized"
        case .notDetermined:
            return "Not Requested"
        case .denied:
            return "Denied"
        }
    }

    var permissionStatusDescription: String {
        switch permissionState {
        case .authorized:
            return "Xpendo can schedule local reminders on this device."
        case .notDetermined:
            return "Turn on notifications below to request permission in context."
        case .denied:
            return "Notification permission is denied. Re-enable it from the system settings if needed."
        }
    }

    var reminderControlsDisabled: Bool {
        !notificationsEnabled || !permissionState.isAuthorized || isProcessing
    }

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
