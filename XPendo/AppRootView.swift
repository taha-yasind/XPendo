import SwiftUI

struct AppRootView: View {
    @State private var isShowingAddExpenseSheet = false

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
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(.white, for: .tabBar)

            FloatingAddButton(action: presentAddExpenseSheet)
                .padding(.bottom, 8)
        }
        .sheet(isPresented: $isShowingAddExpenseSheet) {
            AddExpensePlaceholderView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private func presentAddExpenseSheet() {
        isShowingAddExpenseSheet = true
    }
}

#Preview {
    AppRootView()
}
