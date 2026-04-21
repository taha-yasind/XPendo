import SwiftUI

struct BudgetView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                BudgetHeader()

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Monthly Budget Snapshot")
                            .font(.headline)
                            .foregroundStyle(XPendoTheme.primaryText)

                        VStack(spacing: 18) {
                            BudgetPlaceholderRow(
                                title: "Food",
                                tint: XPendoTheme.accentTeal,
                                progress: 0.72
                            )

                            BudgetPlaceholderRow(
                                title: "Transport",
                                tint: XPendoTheme.housingGreen,
                                progress: 0.46
                            )

                            BudgetPlaceholderRow(
                                title: "Shopping",
                                tint: XPendoTheme.coral,
                                progress: 0.84
                            )
                        }
                    }
                }

                PlaceholderCard(
                    title: "Overspending Alerts Placeholder",
                    systemImage: "exclamationmark.triangle.fill",
                    description: "Budget warnings stay visual-only for now and will become real once budget logic is implemented in Phase 7.",
                    accentColor: XPendoTheme.coral
                )

                PlaceholderCard(
                    title: "Limit Usage Area",
                    systemImage: "chart.bar.xaxis",
                    description: "This screen already reserves clear card sections for remaining budget and progress details.",
                    accentColor: XPendoTheme.softPurple
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 130)
        }
        .background(XPendoTheme.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        BudgetView()
    }
    .background(XPendoTheme.background)
}

private struct BudgetHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Budget")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(XPendoTheme.primaryText)

            Text("A calm placeholder layout for category budgets, progress, and overspending states.")
                .font(.subheadline)
                .foregroundStyle(XPendoTheme.secondaryText)
        }
    }
}

private struct BudgetPlaceholderRow: View {
    let title: String
    let tint: Color
    let progress: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(XPendoTheme.primaryText)

                Spacer()

                SkeletonLine(width: 52, height: 10)
            }

            PlaceholderProgressBar(tint: tint, progress: progress)

            HStack {
                SkeletonLine(width: 74, height: 10)
                Spacer()
                SkeletonLine(width: 60, height: 10)
            }
        }
    }
}
