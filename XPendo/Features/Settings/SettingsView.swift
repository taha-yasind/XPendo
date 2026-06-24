/*
 DOSYA: SettingsView.swift
 AMAÇ: Currency, language, notification, demo mode ve data action tercihlerini gösterir. User settings değerlerini SettingsViewModel’e bağlar.
 KULLANAN: AppRootView tab navigation, SettingsViewModel ve NotificationSettingsViewModel tarafından kullanılır.
*/
import SwiftData
import SwiftUI

// SettingsView, notification, theme, language, currency ve utility ayarlarının ekranıdır.
// Draft state kullanır; değişiklikler kullanıcı Apply dediğinde SwiftData AppSettings'e yazılır.
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @Query private var settings: [AppSettings]
    @Query private var expenses: [Expense]
    @Query private var budgets: [Budget]

    @State private var notificationViewModel = NotificationSettingsViewModel()
    @State private var settingsViewModel = SettingsViewModel()
    @State private var isShowingResetSheet = false
    @State private var isShowingDemoActivationSheet = false
    @State private var isShowingOnboardingAgain = false
    @State private var hasInitializedDraft = false
    @State private var draftNotificationsEnabled = false
    @State private var draftDailyReminderEnabled = false
    @State private var draftBudgetWarningEnabled = false
    @State private var draftCurrencyCode = CurrencyConverter.supportedCurrencyCode(from: Locale.current.currency?.identifier)
    @State private var draftThemeCode = PreferredTheme.light.rawValue
    @State private var draftLanguageCode = AppLanguage.resolved(from: nil).rawValue

    // Bu view için görünen SwiftUI layout’unu kurar.
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                notificationSection
                preferencesSection
                iCloudSyncSection
                utilitiesSection
                aboutSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, hasPendingChanges ? 104 : 32)
        }
        .background(XPendoTheme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .preference(key: MainChromeHiddenPreferenceKey.self, value: true)
        .safeAreaInset(edge: .bottom) {
            // Pending preference değişikliği varsa ekran altında apply bar gösterilir.
            if hasPendingChanges {
                applyBar
            }
        }
        .task(id: settingsLoadKey) {
            // Settings ve permission state SwiftData + system notification state üzerinden yüklenir.
            await notificationViewModel.load(from: currentSettings)
            settingsViewModel.load(from: currentSettings)

            if !hasInitializedDraft || !hasPendingChanges {
                syncDraftValues()
                hasInitializedDraft = true
            }
        }
        .sheet(isPresented: $isShowingResetSheet) {
            ResetDataConfirmationSheet(
                title: clearDataConfirmationTitle,
                subtitle: AppLocalization.string("settings.utility.clear.confirm.subtitle"),
                summary: recordedDataSummary,
                isDeleting: settingsViewModel.isResettingData,
                onDelete: {
                    // Bu synchronous context içinden async work çalıştırır.
                    Task {
                        // Async operation tamamlanana kadar bekler.
                        await settingsViewModel.clearRecordedData(modelContext: modelContext)

                        if settingsViewModel.errorMessage == nil {
                            isShowingResetSheet = false
                        }
                    }
                },
                onCancel: {
                    isShowingResetSheet = false
                }
            )
            .interactiveDismissDisabled(settingsViewModel.isResettingData)
            .presentationDetents([.height(248)])
            .presentationDragIndicator(.visible)
            .presentationBackground(XPendoTheme.surfaceBackground)
        }
        .sheet(isPresented: $isShowingDemoActivationSheet) {
            DemoModeActivationSheet(
                onConfirm: {
                    settingsViewModel.setDemoModeEnabled(true)
                    isShowingDemoActivationSheet = false
                },
                onCancel: {
                    isShowingDemoActivationSheet = false
                }
            )
            .presentationDetents([.height(250)])
            .presentationDragIndicator(.visible)
            .presentationBackground(XPendoTheme.surfaceBackground)
        }
        .fullScreenCover(isPresented: $isShowingOnboardingAgain) {
            // Kullanıcı onboarding anlatımını Settings içinden tekrar izleyebilir; ilk açılış flag'i değişmez.
            OnboardingView(mode: .replay) {
                isShowingOnboardingAgain = false
            }
            .environment(\.locale, AppLocalization.locale)
        }
        .alert(AppLocalization.string("settings.alert.updateFailed.title"), isPresented: errorBinding) {
            Button(AppLocalization.string("common.ok"), role: .cancel) {
                clearErrorMessages()
            }
        } message: {
            Text(activeErrorMessage ?? AppLocalization.string("common.tryAgain"))
        }
    }

    // iCloud bölümü, CloudKit hazır tasarım kararını açıklar; aktif sync davranışı burada başlatılmaz.
    private var iCloudSyncSection: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 18) {
                SettingsSectionHeader(
                    title: AppLocalization.string("settings.icloud.title"),
                    description: AppLocalization.string("settings.icloud.description")
                )

                SettingsInfoRow(
                    title: AppLocalization.string("settings.icloud.ready.title"),
                    subtitle: AppLocalization.string("settings.icloud.ready.subtitle"),
                    icon: "icloud.fill",
                    value: AppLocalization.string("settings.icloud.status.planned"),
                    accentColor: XPendoTheme.accentTeal
                )

                Text(AppLocalization.string("settings.icloud.footnote"))
                    .font(.caption)
                    .foregroundStyle(XPendoTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(AppLocalization.string("Settings"))
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(XPendoTheme.primaryText)

            Text(AppLocalization.string("Manage reminders, choose your preferred theme, set the app currency, and apply changes only when you are ready."))
                .font(.subheadline)
                .foregroundStyle(XPendoTheme.secondaryText)
        }
    }

    // Notification section, draft toggle'ları tutar; gerçek kayıt apply akışında yapılır.
    private var notificationSection: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 16) {
                    SettingsSectionHeader(
                        title: AppLocalization.string("Notifications"),
                        description: notificationViewModel.permissionStatusDescription
                    )

                    Spacer(minLength: 12)

                    Text(notificationViewModel.permissionStatusTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(permissionStatusColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(permissionStatusColor.opacity(0.12), in: Capsule())
                }

                VStack(spacing: 12) {
                    NotificationToggleRow(
                        title: AppLocalization.string("Allow Notifications"),
                        subtitle: AppLocalization.string("Request permission and let Xpendo schedule local reminders."),
                        icon: "bell.badge.fill",
                        isOn: $draftNotificationsEnabled,
                        isDisabled: isApplyLocked
                    )

                    NotificationToggleRow(
                        title: AppLocalization.string("Daily Reminder"),
                        subtitle: AppLocalization.string("Sends a daily reminder at 8:00 PM to log expenses."),
                        icon: "clock.fill",
                        isOn: $draftDailyReminderEnabled,
                        isDisabled: draftReminderControlsDisabled
                    )

                    NotificationToggleRow(
                        title: AppLocalization.string("Budget Warning"),
                        subtitle: AppLocalization.string("Schedules a daily warning at 6:00 PM when a current monthly budget is exceeded."),
                        icon: "exclamationmark.triangle.fill",
                        isOn: $draftBudgetWarningEnabled,
                        isDisabled: draftReminderControlsDisabled
                    )
                }

                if let infoMessage = notificationViewModel.infoMessage {
                    SettingsFeedbackBanner(
                        text: infoMessage,
                        tone: .info,
                        icon: "info.circle.fill"
                    )
                }
            }
        }
    }

    // Preferences section, theme/language/currency draft seçimlerini yönetir.
    private var preferencesSection: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 18) {
                SettingsSectionHeader(
                    title: AppLocalization.string("Preferences"),
                    description: AppLocalization.string("Choose the appearance and currency that Xpendo should keep using.")
                )

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(AppLocalization.string("Preferred Theme"))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(XPendoTheme.primaryText)

                            Text(AppLocalization.string("Swipe or tap to keep Xpendo in the look you prefer."))
                                .font(.caption)
                                .foregroundStyle(XPendoTheme.secondaryText)
                        }

                        Spacer(minLength: 12)

                        Text(settingsViewModel.themeName(for: draftThemeCode))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(XPendoTheme.accentTeal)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(XPendoTheme.accentTeal.opacity(0.12), in: Capsule())
                    }

                    ThemeSelectorControl(
                        options: settingsViewModel.themeOptions,
                        selection: themeSelectionBinding,
                        isDisabled: currentSettings == nil || isApplyLocked
                    )
                }

                Menu {
                    ForEach(settingsViewModel.languageOptions) { option in
                        Button {
                            draftLanguageCode = option.code
                        } label: {
                            if option.code == draftLanguageCode {
                                Label(option.title, systemImage: "checkmark")
                            } else {
                                Text(option.title)
                            }
                        }
                    }
                } label: {
                    SettingsMenuRow(
                        title: AppLocalization.string("settings.preferences.language.title"),
                        subtitle: settingsViewModel.languageName(for: draftLanguageCode),
                        icon: "globe",
                        value: draftLanguageCode.uppercased(),
                        accentColor: XPendoTheme.accentTeal,
                        isLoading: settingsViewModel.isUpdatingPreferences
                    )
                }
                .buttonStyle(.plain)
                .disabled(currentSettings == nil || isApplyLocked)

                Menu {
                    ForEach(settingsViewModel.currencyOptions) { option in
                        Button {
                            draftCurrencyCode = option.code
                        } label: {
                            if option.code == draftCurrencyCode {
                                Label(option.displayTitle, systemImage: "checkmark")
                            } else {
                                Text(option.displayTitle)
                            }
                        }
                    }
                } label: {
                    SettingsMenuRow(
                        title: AppLocalization.string("Currency"),
                        subtitle: settingsViewModel.currencyName(for: draftCurrencyCode),
                        icon: "dollarsign.circle.fill",
                        value: draftCurrencyCode,
                        accentColor: XPendoTheme.accentTeal,
                        isLoading: settingsViewModel.isUpdatingPreferences
                    )
                }
                .buttonStyle(.plain)
                .disabled(currentSettings == nil || isApplyLocked)
            }
        }
    }

    // Utilities section, demo data, onboarding replay ve recorded data temizleme aksiyonlarını toplar.
    private var utilitiesSection: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 18) {
                SettingsSectionHeader(
                    title: AppLocalization.string("Utilities"),
                    description: AppLocalization.string("Use this only when you want a clean slate for recorded expenses and monthly budgets.")
                )

                NotificationToggleRow(
                    title: AppLocalization.string("settings.demo.toggle.title"),
                    subtitle: AppLocalization.string("settings.demo.toggle.subtitle"),
                    icon: "wand.and.stars",
                    isOn: demoModeBinding,
                    isDisabled: settingsViewModel.isBusy
                )

                Button {
                    isShowingOnboardingAgain = true
                } label: {
                    SettingsActionRow(
                        title: AppLocalization.string("settings_show_onboarding_again"),
                        subtitle: AppLocalization.string("settings_show_onboarding_again_subtitle"),
                        icon: "play.circle.fill",
                        accentColor: XPendoTheme.accentTeal,
                        actionTitle: AppLocalization.string("settings_show_onboarding_again_action")
                    )
                }
                .buttonStyle(.plain)

                Button {
                    // Bu synchronous context içinden async work çalıştırır.
                    Task {
                        // Async operation tamamlanana kadar bekler.
                        await settingsViewModel.loadDemoData(modelContext: modelContext)
                    }
                } label: {
                    SettingsActionRow(
                        title: AppLocalization.string("settings.demo.load.title"),
                        subtitle: AppLocalization.string("settings.demo.load.subtitle"),
                        icon: "tray.and.arrow.down.fill",
                        accentColor: XPendoTheme.softPurple,
                        actionTitle: AppLocalization.string("settings.demo.load.action")
                    )
                }
                .buttonStyle(.plain)
                .disabled(demoDataControlsDisabled)
                .opacity(demoDataControlsDisabled ? 0.58 : 1)

                Button {
                    isShowingResetSheet = true
                } label: {
                    SettingsActionRow(
                        title: clearDataActionTitle,
                        subtitle: recordedDataSummary,
                        icon: "trash.fill",
                        accentColor: XPendoTheme.coral,
                        actionTitle: hasRecordedData ? AppLocalization.string("Clear") : AppLocalization.string("Empty")
                    )
                }
                .buttonStyle(.plain)
                .disabled(!hasRecordedData || settingsViewModel.isBusy)
                .opacity(!hasRecordedData ? 0.6 : 1)

                if let utilityMessage = settingsViewModel.utilityMessage {
                    SettingsFeedbackBanner(
                        text: utilityMessage.text,
                        tone: utilityMessage.tone,
                        icon: utilityMessage.tone == .success ? "checkmark.circle.fill" : "info.circle.fill"
                    )
                }
            }
        }
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var aboutSection: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 18) {
                SettingsSectionHeader(
                    title: AppLocalization.string("About Xpendo"),
                    description: AppLocalization.string("A focused personal expense tracker that stays local, simple, and easy to understand.")
                )

                VStack(spacing: 12) {
                    SettingsInfoRow(
                        title: AppLocalization.string("Version"),
                        subtitle: AppLocalization.string("Current app release"),
                        icon: "app.badge.fill",
                        value: settingsViewModel.versionValue,
                        accentColor: XPendoTheme.accentTeal
                    )

                    SettingsInfoRow(
                        title: AppLocalization.string("Built With"),
                        subtitle: AppLocalization.string("Core app technologies"),
                        icon: "hammer.fill",
                        value: "SwiftUI + SwiftData",
                        accentColor: XPendoTheme.softPurple
                    )

                    SettingsInfoRow(
                        title: AppLocalization.string("Reminders"),
                        subtitle: AppLocalization.string("Delivery model"),
                        icon: "bell.badge.fill",
                        value: AppLocalization.string("Local notifications only"),
                        accentColor: XPendoTheme.freshGreen
                    )
                }
            }
        }
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var applyBar: some View {
        Button {
            // Bu synchronous context içinden async work çalıştırır.
            Task {
                // Async operation tamamlanana kadar bekler.
                await applyChanges()
            }
        } label: {
            HStack(spacing: 10) {
                if isApplyLocked {
                    ProgressView()
                        .tint(.white)
                }

                Text(AppLocalization.string("Apply"))
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(XPendoTheme.accentTeal)
            )
            .shadow(color: XPendoTheme.accentTeal.opacity(0.2), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .disabled(isApplyLocked || currentSettings == nil)
        .opacity(isApplyLocked || currentSettings == nil ? 0.65 : 1)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(XPendoTheme.background.opacity(0.98))
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var currentSettings: AppSettings? {
        settings.first
    }

    // User setting veya state değişikliğini uygular.
    private var settingsLoadKey: String {
        let appSettings = currentSettings

        return [
            String(describing: scenePhase),
            CurrencyConverter.supportedCurrencyCode(from: appSettings?.currencyCode),
            PreferredTheme.resolved(from: appSettings?.preferredThemeCode).rawValue,
            AppLanguage.resolved(from: appSettings?.preferredLanguageCode).rawValue,
            String(appSettings?.notificationsEnabled ?? false),
            String(appSettings?.dailyReminderEnabled ?? false),
            String(appSettings?.budgetWarningEnabled ?? false)
        ].joined(separator: "|")
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var hasRecordedData: Bool {
        !expenses.isEmpty || !budgets.isEmpty
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var isDemoModeActive: Bool {
        settingsViewModel.isDemoModeEnabled
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var demoDataControlsDisabled: Bool {
        !isDemoModeActive || settingsViewModel.isBusy
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var clearDataActionTitle: String {
        isDemoModeActive ? "settings.utility.clear.demo.title" : "settings.utility.clear.standard.title"
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var clearDataConfirmationTitle: String {
        isDemoModeActive ? "settings.utility.clear.demo.confirm.title" : "settings.utility.clear.standard.confirm.title"
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var recordedDataSummary: String {
        if hasRecordedData {
            return AppLocalization.format(
                "settings.utility.summary.withData",
                countText(for: expenses.count, singularKey: "settings.count.expense.singular", pluralKey: "settings.count.expense.plural"),
                countText(for: budgets.count, singularKey: "settings.count.budget.singular", pluralKey: "settings.count.budget.plural")
            )
        }

        return AppLocalization.string("settings.utility.summary.empty")
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var hasPendingChanges: Bool {
        // Gerekli data eksikse erken çıkış yapar.
        guard hasInitializedDraft else {
            return false
        }

        return draftCurrencyCode != CurrencyConverter.supportedCurrencyCode(from: currentSettings?.currencyCode ?? settingsViewModel.currencyCode)
            || draftThemeCode != PreferredTheme.resolved(from: currentSettings?.preferredThemeCode ?? settingsViewModel.preferredThemeCode).rawValue
            || draftLanguageCode != AppLanguage.resolved(from: currentSettings?.preferredLanguageCode ?? settingsViewModel.preferredLanguageCode).rawValue
            || draftNotificationsEnabled != (currentSettings?.notificationsEnabled ?? notificationViewModel.notificationsEnabled)
            || draftDailyReminderEnabled != (currentSettings?.dailyReminderEnabled ?? notificationViewModel.dailyReminderEnabled)
            || draftBudgetWarningEnabled != (currentSettings?.budgetWarningEnabled ?? notificationViewModel.budgetWarningEnabled)
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var draftReminderControlsDisabled: Bool {
        !draftNotificationsEnabled || notificationViewModel.permissionState == .denied || isApplyLocked
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var isApplyLocked: Bool {
        notificationViewModel.isProcessing || settingsViewModel.isBusy
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var permissionStatusColor: Color {
        switch notificationViewModel.permissionState {
        case .authorized:
            return XPendoTheme.freshGreen
        case .notDetermined:
            return XPendoTheme.accentTeal
        case .denied:
            return XPendoTheme.coral
        }
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var activeErrorMessage: String? {
        notificationViewModel.errorMessage ?? settingsViewModel.errorMessage
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var errorBinding: Binding<Bool> {
        Binding(
            get: { activeErrorMessage != nil },
            set: { newValue in
                if !newValue {
                    clearErrorMessages()
                }
            }
        )
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private func syncDraftValues() {
        draftNotificationsEnabled = notificationViewModel.notificationsEnabled
        draftDailyReminderEnabled = notificationViewModel.dailyReminderEnabled
        draftBudgetWarningEnabled = notificationViewModel.budgetWarningEnabled
        draftCurrencyCode = settingsViewModel.currencyCode
        draftThemeCode = settingsViewModel.preferredThemeCode
        draftLanguageCode = settingsViewModel.preferredLanguageCode
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private func applyChanges() async {
        // Gerekli data eksikse erken çıkış yapar.
        guard let currentSettings else {
            settingsViewModel.errorMessage = AppLocalization.string("error.preferencesUnavailable")
            return
        }

        clearErrorMessages()

        // Async operation tamamlanana kadar bekler.
        await settingsViewModel.updateDisplayPreferences(
            currencyCode: draftCurrencyCode,
            preferredThemeCode: draftThemeCode,
            preferredLanguageCode: draftLanguageCode,
            settings: currentSettings,
            modelContext: modelContext
        )

        // Gerekli data eksikse erken çıkış yapar.
        guard settingsViewModel.errorMessage == nil else {
            syncDraftValues()
            return
        }

        // Async operation tamamlanana kadar bekler.
        await notificationViewModel.applyChanges(
            notificationsEnabled: draftNotificationsEnabled,
            dailyReminderEnabled: draftDailyReminderEnabled,
            budgetWarningEnabled: draftBudgetWarningEnabled,
            settings: currentSettings,
            modelContext: modelContext
        )

        syncDraftValues()
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private func clearErrorMessages() {
        notificationViewModel.errorMessage = nil
        settingsViewModel.errorMessage = nil
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private func countText(for count: Int, singularKey: String, pluralKey: String) -> String {
        let unit = count == 1 ? AppLocalization.string(singularKey) : AppLocalization.string(pluralKey)
        return "\(count) \(unit)"
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var themeSelectionBinding: Binding<PreferredTheme> {
        Binding(
            get: { PreferredTheme.resolved(from: draftThemeCode) },
            set: { draftThemeCode = $0.rawValue }
        )
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var demoModeBinding: Binding<Bool> {
        Binding(
            get: { settingsViewModel.isDemoModeEnabled },
            set: { isEnabled in
                if isEnabled {
                    if !settingsViewModel.isDemoModeEnabled {
                        isShowingDemoActivationSheet = true
                    }
                } else {
                    settingsViewModel.setDemoModeEnabled(false)
                }
            }
        )
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .modelContainer(XPendoModelContainer.shared)
    }
    .background(XPendoTheme.background)
}

// App tarafından kullanılan lightweight value type tanımlar.
private struct SettingsSectionHeader: View {
    let title: String
    let description: String

    // Bu view için görünen SwiftUI layout’unu kurar.
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundStyle(XPendoTheme.primaryText)

            Text(description)
                .font(.subheadline)
                .foregroundStyle(XPendoTheme.secondaryText)
        }
    }
}

// App tarafından kullanılan lightweight value type tanımlar.
private struct SettingsMenuRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let value: String
    let accentColor: Color
    let isLoading: Bool

    // Bu view için görünen SwiftUI layout’unu kurar.
    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(accentColor.opacity(0.12))
                .frame(width: 42, height: 42)
                .overlay {
                    Image(systemName: icon)
                        .foregroundStyle(accentColor)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(XPendoTheme.primaryText)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(XPendoTheme.secondaryText)
            }

            Spacer()

            if isLoading {
                ProgressView()
                    .tint(accentColor)
            } else {
                HStack(spacing: 8) {
                    Text(value)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(accentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(accentColor.opacity(0.12), in: Capsule())

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(XPendoTheme.secondaryText)
                }
            }
        }
        .padding(14)
        .background(XPendoTheme.inputBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// App tarafından kullanılan lightweight value type tanımlar.
private struct SettingsActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    let actionTitle: String

    // Bu view için görünen SwiftUI layout’unu kurar.
    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(accentColor.opacity(0.12))
                .frame(width: 42, height: 42)
                .overlay {
                    Image(systemName: icon)
                        .foregroundStyle(accentColor)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(XPendoTheme.primaryText)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(XPendoTheme.secondaryText)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            Text(actionTitle)
                .font(.caption.weight(.semibold))
                .foregroundStyle(accentColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(accentColor.opacity(0.12), in: Capsule())
        }
        .padding(14)
        .background(XPendoTheme.inputBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// App tarafından kullanılan lightweight value type tanımlar.
private struct SettingsInfoRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let value: String
    let accentColor: Color

    // Bu view için görünen SwiftUI layout’unu kurar.
    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(accentColor.opacity(0.12))
                .frame(width: 42, height: 42)
                .overlay {
                    Image(systemName: icon)
                        .foregroundStyle(accentColor)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(XPendoTheme.primaryText)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(XPendoTheme.secondaryText)
            }

            Spacer()

            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(XPendoTheme.primaryText)
                .multilineTextAlignment(.trailing)
        }
        .padding(14)
        .background(XPendoTheme.inputBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// App tarafından kullanılan lightweight value type tanımlar.
private struct SettingsFeedbackBanner: View {
    let text: String
    let tone: SettingsViewModel.UtilityMessage.Tone
    let icon: String

    // Bu view için görünen SwiftUI layout’unu kurar.
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(tintColor)

            Text(text)
                .font(.caption)
                .foregroundStyle(XPendoTheme.secondaryText)
        }
        .padding(14)
        .background(tintColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var tintColor: Color {
        switch tone {
        case .success:
            return XPendoTheme.freshGreen
        case .info:
            return XPendoTheme.softPurple
        }
    }
}

// App tarafından kullanılan lightweight value type tanımlar.
private struct NotificationToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool
    let isDisabled: Bool

    // Bu view için görünen SwiftUI layout’unu kurar.
    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(iconBackgroundColor)
                .frame(width: 42, height: 42)
                .overlay {
                    Image(systemName: icon)
                        .foregroundStyle(iconTintColor)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(titleColor)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(subtitleColor)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(XPendoTheme.accentTeal)
                .disabled(isDisabled)
        }
        .padding(14)
        .background(rowBackgroundColor, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .opacity(isDisabled ? 0.58 : 1)
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var rowBackgroundColor: Color {
        isDisabled ? XPendoTheme.placeholder.opacity(0.3) : XPendoTheme.inputBackground
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var iconBackgroundColor: Color {
        isDisabled ? XPendoTheme.secondaryText.opacity(0.08) : XPendoTheme.accentTeal.opacity(0.12)
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var iconTintColor: Color {
        isDisabled ? XPendoTheme.secondaryText.opacity(0.75) : XPendoTheme.accentTeal
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var titleColor: Color {
        isDisabled ? XPendoTheme.secondaryText.opacity(0.92) : XPendoTheme.primaryText
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var subtitleColor: Color {
        isDisabled ? XPendoTheme.secondaryText.opacity(0.9) : XPendoTheme.secondaryText
    }
}

// App tarafından kullanılan lightweight value type tanımlar.
private struct ResetDataConfirmationSheet: View {
    let title: String
    let subtitle: String
    let summary: String
    let isDeleting: Bool
    let onDelete: () -> Void
    let onCancel: () -> Void

    // Bu view için görünen SwiftUI layout’unu kurar.
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(XPendoTheme.coral.opacity(0.12))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: "trash.fill")
                            .foregroundStyle(XPendoTheme.coral)
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(XPendoTheme.primaryText)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(XPendoTheme.secondaryText)
                }
            }

            Text(summary)
                .font(.subheadline)
                .foregroundStyle(XPendoTheme.secondaryText)

            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text(AppLocalization.string("common.cancel"))
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(XPendoTheme.inputBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                Button(action: onDelete) {
                    HStack(spacing: 8) {
                        if isDeleting {
                            ProgressView()
                                .tint(.white)
                        }

                        Text(AppLocalization.string("common.delete"))
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(XPendoTheme.coral, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(isDeleting)
                .opacity(isDeleting ? 0.7 : 1)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(XPendoTheme.surfaceBackground)
    }
}

// App tarafından kullanılan lightweight value type tanımlar.
private struct DemoModeActivationSheet: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void

    // Bu view için görünen SwiftUI layout’unu kurar.
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(XPendoTheme.softPurple.opacity(0.12))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: "sparkles")
                            .foregroundStyle(XPendoTheme.softPurple)
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text(AppLocalization.string("settings.demo.confirm.title"))
                        .font(.headline)
                        .foregroundStyle(XPendoTheme.primaryText)

                    Text(AppLocalization.string("settings.demo.confirm.subtitle"))
                        .font(.caption)
                        .foregroundStyle(XPendoTheme.secondaryText)
                }
            }

            Text(AppLocalization.string("settings.demo.confirm.description"))
                .font(.subheadline)
                .foregroundStyle(XPendoTheme.secondaryText)

            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text(AppLocalization.string("common.cancel"))
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(XPendoTheme.inputBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                Button(action: onConfirm) {
                    Text(AppLocalization.string("settings.demo.confirm.action"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(XPendoTheme.softPurple, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(XPendoTheme.surfaceBackground)
    }
}

// App tarafından kullanılan lightweight value type tanımlar.
private struct ThemeSelectorControl: View {
    let options: [SettingsViewModel.ThemeOption]
    @Binding var selection: PreferredTheme
    let isDisabled: Bool

    // Bu view için görünen SwiftUI layout’unu kurar.
    var body: some View {
        GeometryReader { proxy in
            let optionCount = max(options.count, 1)
            let segmentWidth = proxy.size.width / CGFloat(optionCount)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(XPendoTheme.inputBackground)

                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(XPendoTheme.selectedSurface)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(XPendoTheme.cardBorder, lineWidth: 1)
                    }
                    .frame(width: max(segmentWidth - 8, 0), height: 52)
                    .offset(x: 4 + (CGFloat(currentIndex) * segmentWidth))
                    .shadow(color: XPendoTheme.cardShadow.opacity(0.8), radius: 10, x: 0, y: 5)

                HStack(spacing: 0) {
                    ForEach(options) { option in
                        Button {
                            updateSelection(option.theme)
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: option.systemImage)
                                    .font(.subheadline.weight(.semibold))

                                Text(option.title)
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundStyle(selection == option.theme ? XPendoTheme.primaryText : XPendoTheme.secondaryText)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(XPendoTheme.cardBorder, lineWidth: 1)
            }
            .gesture(
                DragGesture(minimumDistance: 8)
                    .onChanged { value in
                        // Gerekli data eksikse erken çıkış yapar.
                        guard !isDisabled else {
                            return
                        }

                        let index = resolvedIndex(for: value.location.x, width: proxy.size.width)
                        updateSelection(options[index].theme)
                    }
            )
        }
        .frame(height: 60)
        .opacity(isDisabled ? 0.6 : 1)
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var currentIndex: Int {
        options.firstIndex(where: { $0.theme == selection }) ?? 0
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private func resolvedIndex(for locationX: CGFloat, width: CGFloat) -> Int {
        let optionCount = max(options.count, 1)
        let clampedX = min(max(locationX, 0), max(width - 1, 0))
        let rawIndex = Int(clampedX / max(width / CGFloat(optionCount), 1))
        return min(max(rawIndex, 0), optionCount - 1)
    }

    // User setting veya state değişikliğini uygular.
    private func updateSelection(_ theme: PreferredTheme) {
        // Gerekli data eksikse erken çıkış yapar.
        guard !isDisabled, theme != selection else {
            return
        }

        withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
            selection = theme
        }
    }
}
