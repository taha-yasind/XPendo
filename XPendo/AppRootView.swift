/*
 DOSYA: AppRootView.swift
 AMAÇ: Ana app shell, onboarding durumu, demo mode yükleme ve tab navigation akışını koordine eder. Launch sonrası kullanıcının hangi üst seviye ekranı göreceğini belirler.
 KULLANAN: XPendoApp, feature viewleri, AppModeStore ve SwiftData model context tarafından kullanılır.
*/
import SwiftData
import SwiftUI
import UIKit

// AppRootView, onboarding kararı, ana tab navigation ve global app ayarlarını yönetir.
// SwiftData'dan AppSettings okuyarak theme, language ve notification sync akışını başlatır.
struct MainChromeHiddenPreferenceKey: PreferenceKey {
    static let defaultValue = false

    // Bu type için odaklı bir davranış parçasını yönetir.
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

// Uygulamanın ana SwiftUI kök View'udur.
// İlk açılışta onboarding gösterir; sonrasında Home, Expenses, Budget ve Analytics tablarını sunar.
struct AppRootView: View {
    // MainTabView ayrı dosyada değildir; tab state'i bu enum ile AppRootView içinde tutulur.
    private enum AppTab: Hashable {
        case home
        case expenses
        case budget
        case analytics
    }

    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var settings: [AppSettings]

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    @State private var isShowingAddExpenseSheet = false
    @State private var isMainChromeHidden = false
    @State private var isKeyboardVisible = false
    @State private var selectedTab: AppTab = .home
    @State private var localeRefreshID = UUID()

    // Bu view için görünen SwiftUI layout’unu kurar.
    var body: some View {
        Group {
            // Onboarding kararı AppStorage ile kalıcı tutulur ve launch akışını belirler.
            if hasSeenOnboarding {
                mainAppContent
            } else {
                OnboardingView(mode: .firstLaunch) {
                    hasSeenOnboarding = true
                }
            }
        }
        .environment(\.locale, appLocale)
        .id("\(selectedLanguageCode)-\(localeRefreshID)")
        .sheet(isPresented: $isShowingAddExpenseSheet) {
            AddExpenseView()
                .environment(\.locale, appLocale)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .preferredColorScheme(preferredColorScheme)
        .onAppear {
            let previousCode = AppLocalization.currentLanguageCode
            AppLocalization.updateLanguage(code: selectedLanguageCode)
            if previousCode != selectedLanguageCode {
                localeRefreshID = UUID()
            }
        }
        .task {
            // Async operation tamamlanana kadar bekler.
            await observeKeyboardVisibility()
        }
        .onChange(of: selectedLanguageCode) { _, newCode in
            AppLocalization.updateLanguage(code: newCode)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // Bu synchronous context içinden async work çalıştırır.
                Task {
                    // App foreground'a döndüğünde notification schedule güncel harcama/budget verisiyle yenilenir.
                    try? await NotificationSyncService.refresh(using: modelContext)
                }
            }
        }
    }

    // Ana tab navigation burada kurulur; her tab kendi NavigationStack'i içinde çalışır.
    private var mainAppContent: some View {
        ZStack(alignment: .bottom) {
            XPendoTheme.background
                .ignoresSafeArea()

            TabView(selection: $selectedTab) {
                NavigationStack {
                    HomeView(onViewAllExpenses: {
                        selectedTab = .expenses
                    })
                }
                .tabItem {
                    Label(AppLocalization.string("tab.home"), systemImage: "house")
                }
                .tag(AppTab.home)

                NavigationStack {
                    ExpensesView()
                }
                .tabItem {
                    Label(AppLocalization.string("tab.expenses"), systemImage: "list.bullet.rectangle")
                }
                .tag(AppTab.expenses)

                NavigationStack {
                    BudgetView()
                }
                .tabItem {
                    Label(AppLocalization.string("tab.budget"), systemImage: "wallet.pass")
                }
                .tag(AppTab.budget)

                NavigationStack {
                    AnalyticsView()
                }
                .tabItem {
                    Label(AppLocalization.string("tab.analytics"), systemImage: "chart.pie")
                }
                .tag(AppTab.analytics)
            }
            .tint(XPendoTheme.accentTeal)
            // Settings gibi tam ekran odak isteyen ekranlar tab bar ve floating button'ı gizleyebilir.
            .toolbar(isMainChromeHidden ? .hidden : .visible, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(XPendoTheme.tabBarBackground, for: .tabBar)
            .onPreferenceChange(MainChromeHiddenPreferenceKey.self) { isHidden in
                isMainChromeHidden = isHidden
            }

            if !isMainChromeHidden {
                FloatingAddButton(action: presentAddExpenseSheet)
                    .padding(.bottom, 8)
                    .opacity(isKeyboardVisible ? 0 : 1)
                    .allowsHitTesting(!isKeyboardVisible)
                    .accessibilityHidden(isKeyboardVisible)
            }
        }
    }

    // AppSettings içindeki theme kodu SwiftUI ColorScheme'e çevrilir.
    private var preferredColorScheme: ColorScheme? {
        // Gerekli data eksikse erken çıkış yapar.
        guard let themeCode = settings.first?.preferredThemeCode else {
            return nil
        }
        let theme = PreferredTheme.resolved(from: themeCode)
        return theme.colorScheme
    }

    // Language değiştiğinde View kimliği yenilenerek localized textlerin tekrar çizilmesi sağlanır.
    private var selectedLanguageCode: String {
        AppLanguage.resolved(from: settings.first?.preferredLanguageCode).rawValue
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var appLocale: Locale {
        AppLanguage.resolved(from: settings.first?.preferredLanguageCode).locale
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private func presentAddExpenseSheet() {
        isShowingAddExpenseSheet = true
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private func observeKeyboardVisibility() async {
        // Async operation tamamlanana kadar bekler.
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                for await _ in NotificationCenter.default.notifications(named: UIResponder.keyboardWillShowNotification) {
                    // Async operation tamamlanana kadar bekler.
                    await MainActor.run {
                        setKeyboardVisible(true)
                    }
                }
            }

            group.addTask {
                for await _ in NotificationCenter.default.notifications(named: UIResponder.keyboardWillHideNotification) {
                    // Async operation tamamlanana kadar bekler.
                    await MainActor.run {
                        setKeyboardVisible(false)
                    }
                }
            }
        }
    }

    // User setting veya state değişikliğini uygular.
    private func setKeyboardVisible(_ isVisible: Bool) {
        // Gerekli data eksikse erken çıkış yapar.
        guard isKeyboardVisible != isVisible else {
            return
        }

        isKeyboardVisible = isVisible
    }
}

#Preview {
    AppRootView()
}
