import SwiftData
import SwiftUI

struct MainChromeHiddenPreferenceKey: PreferenceKey {
    static let defaultValue = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

struct AppRootView: View {
    private enum AppTab: Hashable {
        case home
        case expenses
        case budget
        case analytics
    }

    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var settings: [AppSettings]

    @State private var isShowingAddExpenseSheet = false
    @State private var isMainChromeHidden = false
    @State private var selectedTab: AppTab = .home

    var body: some View {
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
                    Label("tab.home", systemImage: "house")
                }
                .tag(AppTab.home)

                NavigationStack {
                    ExpensesView()
                }
                .tabItem {
                    Label("tab.expenses", systemImage: "list.bullet.rectangle")
                }
                .tag(AppTab.expenses)

                NavigationStack {
                    BudgetView()
                }
                .tabItem {
                    Label("tab.budget", systemImage: "wallet.pass")
                }
                .tag(AppTab.budget)

                NavigationStack {
                    AnalyticsView()
                }
                .tabItem {
                    Label("tab.analytics", systemImage: "chart.pie")
                }
                .tag(AppTab.analytics)
            }
            .tint(XPendoTheme.accentTeal)
            .toolbar(isMainChromeHidden ? .hidden : .visible, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(XPendoTheme.tabBarBackground, for: .tabBar)
            .onPreferenceChange(MainChromeHiddenPreferenceKey.self) { isHidden in
                isMainChromeHidden = isHidden
            }

            if !isMainChromeHidden {
                FloatingAddButton(action: presentAddExpenseSheet)
                    .padding(.bottom, 8)
            }
        }
        .environment(\.locale, appLocale)
        .id(selectedLanguageCode)
        .sheet(isPresented: $isShowingAddExpenseSheet) {
            AddExpenseView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .preferredColorScheme(preferredColorScheme)
        .onAppear {
            AppLocalization.updateLanguage(code: selectedLanguageCode)
        }
        .onChange(of: selectedLanguageCode) { _, newCode in
            AppLocalization.updateLanguage(code: newCode)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task {
                    try? await NotificationSyncService.refresh(using: modelContext)
                }
            }
        }
    }

    private var preferredColorScheme: ColorScheme? {
        guard let themeCode = settings.first?.preferredThemeCode else {
            return nil
        }
        let theme = PreferredTheme.resolved(from: themeCode)
        return theme.colorScheme
    }

    private var selectedLanguageCode: String {
        AppLanguage.resolved(from: settings.first?.preferredLanguageCode).rawValue
    }

    private var appLocale: Locale {
        AppLanguage.resolved(from: settings.first?.preferredLanguageCode).locale
    }

    private func presentAddExpenseSheet() {
        isShowingAddExpenseSheet = true
    }
}

#Preview {
    AppRootView()
}
