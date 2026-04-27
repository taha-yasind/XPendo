import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @Query private var settings: [AppSettings]
    @Query private var expenses: [Expense]
    @Query private var budgets: [Budget]

    @State private var notificationViewModel = NotificationSettingsViewModel()
    @State private var settingsViewModel = SettingsViewModel()
    @State private var isShowingResetSheet = false
    @State private var hasInitializedDraft = false
    @State private var draftNotificationsEnabled = false
    @State private var draftDailyReminderEnabled = false
    @State private var draftBudgetWarningEnabled = false
    @State private var draftCurrencyCode = CurrencyConverter.supportedCurrencyCode(from: Locale.current.currency?.identifier)
    @State private var draftThemeCode = PreferredTheme.light.rawValue
    @State private var draftLanguageCode = AppLanguage.resolved(from: nil).rawValue

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                notificationSection
                preferencesSection
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
            if hasPendingChanges {
                applyBar
            }
        }
        .task(id: settingsLoadKey) {
            await notificationViewModel.load(from: currentSettings)
            settingsViewModel.load(from: currentSettings)

            if !hasInitializedDraft || !hasPendingChanges {
                syncDraftValues()
                hasInitializedDraft = true
            }
        }
        .sheet(isPresented: $isShowingResetSheet) {
            ResetDataConfirmationSheet(
                summary: recordedDataSummary,
                isDeleting: settingsViewModel.isResettingData,
                onDelete: {
                    Task {
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
        .alert("settings.alert.updateFailed.title", isPresented: errorBinding) {
            Button("common.ok", role: .cancel) {
                clearErrorMessages()
            }
        } message: {
            Text(activeErrorMessage ?? AppLocalization.string("common.tryAgain"))
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Settings")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(XPendoTheme.primaryText)

            Text("Manage reminders, choose your preferred theme, set the app currency, and apply changes only when you are ready.")
                .font(.subheadline)
                .foregroundStyle(XPendoTheme.secondaryText)
        }
    }

    private var notificationSection: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 16) {
                    SettingsSectionHeader(
                        title: "Notifications",
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
                        title: "Allow Notifications",
                        subtitle: "Request permission and let Xpendo schedule local reminders.",
                        icon: "bell.badge.fill",
                        isOn: $draftNotificationsEnabled,
                        isDisabled: isApplyLocked
                    )

                    NotificationToggleRow(
                        title: "Daily Reminder",
                        subtitle: "Sends a daily reminder at 8:00 PM to log expenses.",
                        icon: "clock.fill",
                        isOn: $draftDailyReminderEnabled,
                        isDisabled: draftReminderControlsDisabled
                    )

                    NotificationToggleRow(
                        title: "Budget Warning",
                        subtitle: "Schedules a daily warning at 6:00 PM when a current monthly budget is exceeded.",
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

    private var preferencesSection: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 18) {
                SettingsSectionHeader(
                    title: "Preferences",
                    description: "Choose the appearance and currency that Xpendo should keep using."
                )

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Preferred Theme")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(XPendoTheme.primaryText)

                            Text("Swipe or tap to keep Xpendo in the look you prefer.")
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
                        title: "settings.preferences.language.title",
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
                        title: "Currency",
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

    private var utilitiesSection: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 18) {
                SettingsSectionHeader(
                    title: "Utilities",
                    description: "Use this only when you want a clean slate for recorded expenses and monthly budgets."
                )

                Button {
                    isShowingResetSheet = true
                } label: {
                    SettingsActionRow(
                        title: "Clear Recorded Data",
                        subtitle: recordedDataSummary,
                        icon: "trash.fill",
                        accentColor: XPendoTheme.coral,
                        actionTitle: hasRecordedData ? "Clear" : "Empty"
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

    private var aboutSection: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 18) {
                SettingsSectionHeader(
                    title: "About Xpendo",
                    description: "A focused personal expense tracker that stays local, simple, and easy to understand."
                )

                VStack(spacing: 12) {
                    SettingsInfoRow(
                        title: "Version",
                        subtitle: "Current app release",
                        icon: "app.badge.fill",
                        value: settingsViewModel.versionValue,
                        accentColor: XPendoTheme.accentTeal
                    )

                    SettingsInfoRow(
                        title: "Built With",
                        subtitle: "Core app technologies",
                        icon: "hammer.fill",
                        value: "SwiftUI + SwiftData",
                        accentColor: XPendoTheme.softPurple
                    )

                    SettingsInfoRow(
                        title: "Reminders",
                        subtitle: "Delivery model",
                        icon: "bell.badge.fill",
                        value: "Local notifications only",
                        accentColor: XPendoTheme.freshGreen
                    )
                }
            }
        }
    }

    private var applyBar: some View {
        Button {
            Task {
                await applyChanges()
            }
        } label: {
            HStack(spacing: 10) {
                if isApplyLocked {
                    ProgressView()
                        .tint(.white)
                }

                Text("Apply")
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

    private var currentSettings: AppSettings? {
        settings.first
    }

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

    private var hasRecordedData: Bool {
        !expenses.isEmpty || !budgets.isEmpty
    }

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

    private var hasPendingChanges: Bool {
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

    private var draftReminderControlsDisabled: Bool {
        !draftNotificationsEnabled || notificationViewModel.permissionState == .denied || isApplyLocked
    }

    private var isApplyLocked: Bool {
        notificationViewModel.isProcessing || settingsViewModel.isBusy
    }

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

    private var activeErrorMessage: String? {
        notificationViewModel.errorMessage ?? settingsViewModel.errorMessage
    }

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

    private func syncDraftValues() {
        draftNotificationsEnabled = notificationViewModel.notificationsEnabled
        draftDailyReminderEnabled = notificationViewModel.dailyReminderEnabled
        draftBudgetWarningEnabled = notificationViewModel.budgetWarningEnabled
        draftCurrencyCode = settingsViewModel.currencyCode
        draftThemeCode = settingsViewModel.preferredThemeCode
        draftLanguageCode = settingsViewModel.preferredLanguageCode
    }

    private func applyChanges() async {
        guard let currentSettings else {
            settingsViewModel.errorMessage = AppLocalization.string("error.preferencesUnavailable")
            return
        }

        clearErrorMessages()

        await settingsViewModel.updateDisplayPreferences(
            currencyCode: draftCurrencyCode,
            preferredThemeCode: draftThemeCode,
            preferredLanguageCode: draftLanguageCode,
            settings: currentSettings,
            modelContext: modelContext
        )

        guard settingsViewModel.errorMessage == nil else {
            syncDraftValues()
            return
        }

        await notificationViewModel.applyChanges(
            notificationsEnabled: draftNotificationsEnabled,
            dailyReminderEnabled: draftDailyReminderEnabled,
            budgetWarningEnabled: draftBudgetWarningEnabled,
            settings: currentSettings,
            modelContext: modelContext
        )

        syncDraftValues()
    }

    private func clearErrorMessages() {
        notificationViewModel.errorMessage = nil
        settingsViewModel.errorMessage = nil
    }

    private func countText(for count: Int, singularKey: String, pluralKey: String) -> String {
        let unit = count == 1 ? AppLocalization.string(singularKey) : AppLocalization.string(pluralKey)
        return "\(count) \(unit)"
    }

    private var themeSelectionBinding: Binding<PreferredTheme> {
        Binding(
            get: { PreferredTheme.resolved(from: draftThemeCode) },
            set: { draftThemeCode = $0.rawValue }
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

private struct SettingsSectionHeader: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(LocalizedStringKey(title))
                .font(.headline)
                .foregroundStyle(XPendoTheme.primaryText)

            Text(LocalizedStringKey(description))
                .font(.subheadline)
                .foregroundStyle(XPendoTheme.secondaryText)
        }
    }
}

private struct SettingsMenuRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let value: String
    let accentColor: Color
    let isLoading: Bool

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
                Text(LocalizedStringKey(title))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(XPendoTheme.primaryText)

                Text(LocalizedStringKey(subtitle))
                    .font(.caption)
                    .foregroundStyle(XPendoTheme.secondaryText)
            }

            Spacer()

            if isLoading {
                ProgressView()
                    .tint(accentColor)
            } else {
                HStack(spacing: 8) {
                    Text(LocalizedStringKey(value))
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

private struct SettingsActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    let actionTitle: String

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
                Text(LocalizedStringKey(title))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(XPendoTheme.primaryText)

                Text(LocalizedStringKey(subtitle))
                    .font(.caption)
                    .foregroundStyle(XPendoTheme.secondaryText)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            Text(LocalizedStringKey(actionTitle))
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

private struct SettingsInfoRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let value: String
    let accentColor: Color

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
                Text(LocalizedStringKey(title))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(XPendoTheme.primaryText)

                Text(LocalizedStringKey(subtitle))
                    .font(.caption)
                    .foregroundStyle(XPendoTheme.secondaryText)
            }

            Spacer()

            Text(LocalizedStringKey(value))
                .font(.caption.weight(.semibold))
                .foregroundStyle(XPendoTheme.primaryText)
                .multilineTextAlignment(.trailing)
        }
        .padding(14)
        .background(XPendoTheme.inputBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct SettingsFeedbackBanner: View {
    let text: String
    let tone: SettingsViewModel.UtilityMessage.Tone
    let icon: String

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

    private var tintColor: Color {
        switch tone {
        case .success:
            return XPendoTheme.freshGreen
        case .info:
            return XPendoTheme.softPurple
        }
    }
}

private struct NotificationToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool
    let isDisabled: Bool

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
                Text(LocalizedStringKey(title))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(titleColor)

                Text(LocalizedStringKey(subtitle))
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

    private var rowBackgroundColor: Color {
        isDisabled ? XPendoTheme.placeholder.opacity(0.3) : XPendoTheme.inputBackground
    }

    private var iconBackgroundColor: Color {
        isDisabled ? XPendoTheme.secondaryText.opacity(0.08) : XPendoTheme.accentTeal.opacity(0.12)
    }

    private var iconTintColor: Color {
        isDisabled ? XPendoTheme.secondaryText.opacity(0.75) : XPendoTheme.accentTeal
    }

    private var titleColor: Color {
        isDisabled ? XPendoTheme.secondaryText.opacity(0.92) : XPendoTheme.primaryText
    }

    private var subtitleColor: Color {
        isDisabled ? XPendoTheme.secondaryText.opacity(0.9) : XPendoTheme.secondaryText
    }
}

private struct ResetDataConfirmationSheet: View {
    let summary: String
    let isDeleting: Bool
    let onDelete: () -> Void
    let onCancel: () -> Void

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
                    Text("Clear Recorded Data?")
                        .font(.headline)
                        .foregroundStyle(XPendoTheme.primaryText)

                    Text("This action cannot be undone.")
                        .font(.caption)
                        .foregroundStyle(XPendoTheme.secondaryText)
                }
            }

            Text(summary)
                .font(.subheadline)
                .foregroundStyle(XPendoTheme.secondaryText)

            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text("common.cancel")
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

                        Text("common.delete")
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

private struct ThemeSelectorControl: View {
    let options: [SettingsViewModel.ThemeOption]
    @Binding var selection: PreferredTheme
    let isDisabled: Bool

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

    private var currentIndex: Int {
        options.firstIndex(where: { $0.theme == selection }) ?? 0
    }

    private func resolvedIndex(for locationX: CGFloat, width: CGFloat) -> Int {
        let optionCount = max(options.count, 1)
        let clampedX = min(max(locationX, 0), max(width - 1, 0))
        let rawIndex = Int(clampedX / max(width / CGFloat(optionCount), 1))
        return min(max(rawIndex, 0), optionCount - 1)
    }

    private func updateSelection(_ theme: PreferredTheme) {
        guard !isDisabled, theme != selection else {
            return
        }

        withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
            selection = theme
        }
    }
}
