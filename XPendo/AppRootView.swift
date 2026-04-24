import SwiftData
import SwiftUI

struct MainChromeHiddenPreferenceKey: PreferenceKey {
    static let defaultValue = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var settings: [AppSettings]

    @State private var isShowingAddExpenseSheet = false
    @State private var isMainChromeHidden = false

    var body: some View {
        ZStack(alignment: .bottom) {
            XPendoTheme.background
                .ignoresSafeArea()

            TabView {
                NavigationStack {
                    HomeView()
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }

                NavigationStack {
                    ExpensesView()
                }
                .tabItem {
                    Label("Expenses", systemImage: "list.bullet.rectangle")
                }

                NavigationStack {
                    BudgetView()
                }
                .tabItem {
                    Label("Budget", systemImage: "wallet.pass")
                }

                NavigationStack {
                    AnalyticsView()
                }
                .tabItem {
                    Label("Analytics", systemImage: "chart.pie")
                }
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
        .sheet(isPresented: $isShowingAddExpenseSheet) {
            AddExpenseView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .preferredColorScheme(preferredTheme.colorScheme)
        .task(id: scenePhase) {
            guard scenePhase == .active else {
                return
            }

            try? await NotificationSyncService.refresh(using: modelContext)
        }
    }

    private func presentAddExpenseSheet() {
        isShowingAddExpenseSheet = true
    }

    private var preferredTheme: PreferredTheme {
        PreferredTheme.resolved(from: settings.first?.preferredThemeCode)
    }
}

#Preview {
    AppRootView()
}
