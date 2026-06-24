/*
 DOSYA: FloatingAddButton.swift
 AMAÇ: Expense creation başlatmak için kullanılan reusable floating action button’ı tanımlar. Add button’ın tablar arasında görsel olarak tutarlı kalmasını sağlar.
 KULLANAN: HomeView, ExpensesView, BudgetView ve diğer feature ekranları tarafından kullanılır.
*/
import SwiftUI

// FloatingAddButton, ana tab ekranlarında ortak Add Expense giriş aksiyonunu temsil eder.
// AppRootView bu butona basıldığında AddExpenseView sheet'ini açar.
struct FloatingAddButton: View {
    let action: () -> Void

    // Bu view için görünen SwiftUI layout’unu kurar.
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [XPendoTheme.accentTeal, XPendoTheme.freshGreen],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 68, height: 68)

                    Image(systemName: "plus")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                }
                .shadow(color: XPendoTheme.accentTeal.opacity(0.32), radius: 18, x: 0, y: 10)

                Text(AppLocalization.string("common.add"))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(XPendoTheme.primaryText)
            }
            .padding(.horizontal, 14)
            .padding(.top, 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(AppLocalization.string("floatingAdd.accessibilityLabel")))
    }
}
