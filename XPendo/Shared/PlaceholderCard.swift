/*
 DOSYA: PlaceholderCard.swift
 AMAÇ: Icon, title ve message içeren reusable empty-state cardları gösterir. Empty screen alanlarına tutarlı bir görsel davranış verir.
 KULLANAN: HomeView, BudgetView, ExpensesView, AnalyticsView ve SettingsView tarafından kullanılır.
*/
import SwiftUI

// PlaceholderCard, geliştirme veya boş içerik durumlarında aynı kart dilini korumak için kullanılır.
struct PlaceholderCard: View {
    let title: String
    let systemImage: String
    let description: String
    var accentColor: Color = XPendoTheme.accentTeal

    // Bu view için görünen SwiftUI layout’unu kurar.
    var body: some View {
        SurfaceCard {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(accentColor.opacity(0.14))
                        .frame(width: 48, height: 48)

                    Image(systemName: systemImage)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(accentColor)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(XPendoTheme.primaryText)

                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(XPendoTheme.secondaryText)
                }

                Spacer(minLength: 0)
            }
        }
    }
}

#Preview {
    PlaceholderCard(
        title: "Monthly Spending",
        systemImage: "chart.bar",
        description: "A placeholder card used to keep the Phase 1 skeleton readable."
    )
    .padding()
    .background(XPendoTheme.background)
}
