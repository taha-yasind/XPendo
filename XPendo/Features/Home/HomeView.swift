import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(
        sort: [
            SortDescriptor(\Expense.date, order: .reverse),
            SortDescriptor(\Expense.createdAt, order: .reverse)
        ]
    ) private var expenses: [Expense]
    @Query private var budgets: [Budget]
    @Query private var settings: [AppSettings]

    private let viewModel = HomeViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                HomeOverviewCard(dashboard: dashboardData, currencyCode: currencyCode)
                HomeRecentExpensesSection(expenses: dashboardData.recentExpenses, currencyCode: currencyCode)
                HomeBudgetPreviewSection(preview: dashboardData.budgetPreview, currencyCode: currencyCode)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 130)
        }
        .background(XPendoTheme.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var dashboardData: HomeDashboardData {
        viewModel.makeDashboardData(expenses: expenses, budgets: budgets)
    }

    private var currencyCode: String {
        CurrencyConverter.supportedCurrencyCode(from: settings.first?.currencyCode)
    }

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Xpendo")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(XPendoTheme.primaryText)

                Text("A clean view of today, \(dashboardData.monthLabel), and your latest activity.")
                    .font(.subheadline)
                    .foregroundStyle(XPendoTheme.secondaryText)
            }

            Spacer()

            NavigationLink {
                SettingsView()
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.headline)
                    .foregroundStyle(XPendoTheme.primaryText)
                    .frame(width: 46, height: 46)
                    .background(XPendoTheme.surfaceBackground, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(XPendoTheme.cardBorder, lineWidth: 1)
                    }
                    .shadow(color: XPendoTheme.cardShadow, radius: 16, x: 0, y: 10)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .modelContainer(XPendoModelContainer.shared)
    }
    .background(XPendoTheme.background)
}

private struct HomeOverviewCard: View {
    let dashboard: HomeDashboardData
    let currencyCode: String

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Label(dashboard.monthLabel, systemImage: "calendar")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(XPendoTheme.secondaryText)

                    Spacer()

                    Text("Overview")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(XPendoTheme.accentTeal, in: Capsule())
                }

                Text(CurrencyConverter.formatFromTRY(dashboard.monthTotal, to: currencyCode))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(XPendoTheme.primaryText)

                Text(monthDescription)
                    .font(.subheadline)
                    .foregroundStyle(XPendoTheme.secondaryText)

                HStack(spacing: 12) {
                    HomeMetricTile(
                        title: "Today's Spending",
                        accentColor: XPendoTheme.accentTeal,
                        primaryContent: {
                            Text(CurrencyConverter.formatFromTRY(dashboard.todayTotal, to: currencyCode))
                        },
                        secondaryText: todayDescription
                    )

                    HomeTopCategoryTile(
                        topCategory: dashboard.topCategory,
                        currencyCode: currencyCode
                    )
                }
            }
        }
    }

    private var monthDescription: String {
        if dashboard.monthExpenseCount == 0 {
            return "No expenses recorded this month yet."
        }

        return "\(dashboard.monthExpenseCount) expenses recorded this month."
    }

    private var todayDescription: String {
        if dashboard.todayExpenseCount == 0 {
            return "No expenses recorded today."
        }

        return "\(dashboard.todayExpenseCount) expenses added today."
    }
}

private struct HomeMetricTile<PrimaryContent: View>: View {
    let title: String
    let accentColor: Color
    let primaryContent: PrimaryContent
    let secondaryText: String

    init(
        title: String,
        accentColor: Color,
        @ViewBuilder primaryContent: () -> PrimaryContent,
        secondaryText: String
    ) {
        self.title = title
        self.accentColor = accentColor
        self.primaryContent = primaryContent()
        self.secondaryText = secondaryText
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(XPendoTheme.primaryText)

            primaryContent
                .font(.title3.weight(.bold))
                .foregroundStyle(XPendoTheme.primaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Text(secondaryText)
                .font(.caption)
                .foregroundStyle(XPendoTheme.secondaryText)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct HomeTopCategoryTile: View {
    let topCategory: HomeTopCategorySummary?
    let currencyCode: String

    var body: some View {
        HomeMetricTile(
            title: "Top Category",
            accentColor: tileColor,
            primaryContent: {
                if let topCategory {
                    HStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(tileColor.opacity(0.18))
                            .frame(width: 34, height: 34)
                            .overlay {
                                Image(systemName: topCategory.icon)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(tileColor)
                            }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(topCategory.name)
                                .font(.subheadline.weight(.bold))

                            Text(CurrencyConverter.formatFromTRY(topCategory.totalAmount, to: currencyCode))
                                .font(.caption.weight(.semibold))
                        }
                    }
                } else {
                    Text("Add expenses to reveal a top category")
                }
            },
            secondaryText: topCategory == nil
                ? "Your highest spending category will appear after a few saved expenses."
                : "Highest spending area this month."
        )
    }

    private var tileColor: Color {
        guard let colorHex = topCategory?.colorHex else {
            return XPendoTheme.softPurple
        }

        return Color(hexString: colorHex) ?? XPendoTheme.softPurple
    }
}

private struct HomeRecentExpensesSection: View {
    let expenses: [Expense]
    let currencyCode: String

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 18) {
                Text("Recent Expenses")
                    .font(.headline)
                    .foregroundStyle(XPendoTheme.primaryText)

                if expenses.isEmpty {
                    HomeInlineEmptyState(
                        systemImage: "tray",
                        title: "No recent activity",
                        description: "Your latest expenses will appear here after you save them."
                    )
                } else {
                    VStack(spacing: 12) {
                        ForEach(expenses) { expense in
                            HomeRecentExpenseRow(expense: expense, currencyCode: currencyCode)
                        }
                    }
                }
            }
        }
    }
}

private struct HomeRecentExpenseRow: View {
    let expense: Expense
    let currencyCode: String

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(categoryColor.opacity(0.14))
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: expense.category.icon)
                        .font(.headline)
                        .foregroundStyle(categoryColor)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(XPendoTheme.primaryText)

                HStack(spacing: 8) {
                    Text(expense.category.name)
                    Text("•")
                    Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                }
                .font(.caption)
                .foregroundStyle(XPendoTheme.secondaryText)
            }

            Spacer()

            Text(CurrencyConverter.formatFromTRY(expense.amount, to: currencyCode))
                .font(.subheadline.weight(.bold))
                .foregroundStyle(XPendoTheme.primaryText)
                .multilineTextAlignment(.trailing)
        }
        .padding(14)
        .background(XPendoTheme.inputBackground, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var categoryColor: Color {
        Color(hexString: expense.category.color) ?? XPendoTheme.accentTeal
    }
}

private struct HomeBudgetPreviewSection: View {
    let preview: HomeBudgetPreview
    let currencyCode: String

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("Budget Preview")
                        .font(.headline)
                        .foregroundStyle(XPendoTheme.primaryText)

                    Spacer()

                    budgetStatusPill
                }

                switch preview {
                case .empty:
                    HomeInlineEmptyState(
                        systemImage: "gauge.with.needle",
                        title: "No monthly budgets yet",
                        description: "This area is ready to show budget progress and warnings once monthly budgets are available."
                    )

                case .tracked(let status):
                    HomeBudgetStatusCard(
                        status: status,
                        currencyCode: currencyCode,
                        accentColor: Color(hexString: status.colorHex) ?? XPendoTheme.freshGreen,
                        footerText: "\(status.trackedBudgetCount) monthly budgets are currently being tracked."
                    )

                case .warning(let status):
                    HomeBudgetStatusCard(
                        status: status,
                        currencyCode: currencyCode,
                        accentColor: XPendoTheme.coral,
                        footerText: warningDescription(for: status.warningCount)
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var budgetStatusPill: some View {
        switch preview {
        case .empty:
            Text("Ready")
                .foregroundStyle(XPendoTheme.secondaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(XPendoTheme.placeholder.opacity(0.55), in: Capsule())

        case .tracked:
            Text("On Track")
                .foregroundStyle(XPendoTheme.freshGreen)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(XPendoTheme.freshGreen.opacity(0.12), in: Capsule())

        case .warning:
            Text("Warning")
                .foregroundStyle(XPendoTheme.coral)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(XPendoTheme.coral.opacity(0.12), in: Capsule())
        }
    }

    private func warningDescription(for warningCount: Int) -> String {
        if warningCount <= 1 {
            return "1 category is currently over its monthly limit."
        }

        return "\(warningCount) categories are currently over their monthly limits."
    }
}

private struct HomeBudgetStatusCard: View {
    let status: HomeBudgetStatus
    let currencyCode: String
    let accentColor: Color
    let footerText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(accentColor.opacity(0.14))
                    .frame(width: 46, height: 46)
                    .overlay {
                        Image(systemName: status.categoryIcon)
                            .font(.headline)
                            .foregroundStyle(accentColor)
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text(status.categoryName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(XPendoTheme.primaryText)

                    Text(status.remainingAmount >= 0 ? "Remaining budget available." : "Monthly limit exceeded.")
                        .font(.caption)
                        .foregroundStyle(XPendoTheme.secondaryText)
                }
            }

            VStack(spacing: 10) {
                HomeBudgetProgressBar(progress: min(max(status.progress, 0), 1), accentColor: accentColor)

                HStack {
                    Text("Spent")
                    Spacer()
                    Text(CurrencyConverter.formatFromTRY(status.spentAmount, to: currencyCode))
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(XPendoTheme.secondaryText)

                HStack {
                    Text(status.remainingAmount >= 0 ? "Remaining" : "Over by")
                    Spacer()
                    Text(CurrencyConverter.formatFromTRY(abs(status.remainingAmount), to: currencyCode))
                        .foregroundStyle(accentColor)
                }
                .font(.caption.weight(.semibold))

                HStack {
                    Text("Limit")
                    Spacer()
                    Text(CurrencyConverter.formatFromTRY(status.limitAmount, to: currencyCode))
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(XPendoTheme.secondaryText)
            }

            Text(footerText)
                .font(.caption)
                .foregroundStyle(XPendoTheme.secondaryText)
        }
        .padding(16)
        .background(XPendoTheme.inputBackground, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct HomeBudgetProgressBar: View {
    let progress: Double
    let accentColor: Color

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(XPendoTheme.placeholder.opacity(0.6))

                Capsule()
                    .fill(accentColor)
                    .frame(width: proxy.size.width * progress)
            }
        }
        .frame(height: 10)
    }
}

private struct HomeInlineEmptyState: View {
    let systemImage: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(XPendoTheme.accentTeal.opacity(0.12))
                .frame(width: 46, height: 46)
                .overlay {
                    Image(systemName: systemImage)
                        .foregroundStyle(XPendoTheme.accentTeal)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(XPendoTheme.primaryText)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(XPendoTheme.secondaryText)
            }
        }
        .padding(16)
        .background(XPendoTheme.inputBackground, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
