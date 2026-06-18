import SwiftUI
import SwiftData

struct HomeView: View {
    let onViewAllExpenses: () -> Void

    @AppStorage(AppModeStore.key) private var isDemoModeEnabled = AppModeStore.isDemoModeEnabled

    @Query(
        sort: [
            SortDescriptor(\Expense.date, order: .reverse),
            SortDescriptor(\Expense.createdAt, order: .reverse)
        ]
    ) private var expenses: [Expense]
    @Query private var budgets: [Budget]
    @Query private var settings: [AppSettings]

    private let viewModel = HomeViewModel()

    init(onViewAllExpenses: @escaping () -> Void = {}) {
        self.onViewAllExpenses = onViewAllExpenses
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                HomeOverviewCard(dashboard: dashboardData, currencyCode: currencyCode)
                HomeRecentExpensesSection(
                    expenses: dashboardData.recentExpenses,
                    currencyCode: currencyCode,
                    onViewAll: onViewAllExpenses
                )
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
                HStack(spacing: 8) {
                    Text("Xpendo")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(XPendoTheme.primaryText)

                    if isDemoModeEnabled {
                        HStack(spacing: 5) {
                            Image(systemName: "star.fill")
                            Text("home.demo.badge")
                        }
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(XPendoTheme.softPurple)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(XPendoTheme.softPurple.opacity(0.12), in: Capsule())
                    }
                }

                Text(AppLocalization.format("home.header.subtitle", dashboardData.monthLabel))
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

                    Text("home.overview.pill")
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
                        title: AppLocalization.string("home.tile.todaySpending"),
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
            return AppLocalization.string("home.monthDescription.empty")
        }

        return AppLocalization.format("home.monthDescription.count", dashboard.monthExpenseCount)
    }

    private var todayDescription: String {
        if dashboard.todayExpenseCount == 0 {
            return AppLocalization.string("home.todayDescription.empty")
        }

        return AppLocalization.format("home.todayDescription.count", dashboard.todayExpenseCount)
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
            title: AppLocalization.string("home.tile.topCategory"),
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
                            Text(CategoryLocalization.localizedName(for: topCategory.name))
                                .font(.subheadline.weight(.bold))

                            Text(CurrencyConverter.formatFromTRY(topCategory.totalAmount, to: currencyCode))
                                .font(.caption.weight(.semibold))
                        }
                    }
                } else {
                    Text("home.topCategory.empty.title")
                }
            },
            secondaryText: topCategory == nil
                ? AppLocalization.string("home.topCategory.empty.description")
                : AppLocalization.string("home.topCategory.filled.description")
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
    let onViewAll: () -> Void

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("home.section.recentExpenses")
                        .font(.headline)
                        .foregroundStyle(XPendoTheme.primaryText)

                    Spacer()

                    Button(action: onViewAll) {
                        Text(AppLocalization.string("home.recent.viewAll"))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(XPendoTheme.accentTeal)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(XPendoTheme.accentTeal.opacity(0.12), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }

                if expenses.isEmpty {
                    HomeInlineEmptyState(
                        systemImage: "tray",
                        title: AppLocalization.string("home.recent.empty.title"),
                        description: AppLocalization.string("home.recent.empty.description")
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
                    Image(systemName: expense.categoryIcon)
                        .font(.headline)
                        .foregroundStyle(categoryColor)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(XPendoTheme.primaryText)

                HStack(spacing: 8) {
                    Text(CategoryLocalization.localizedName(for: expense.categoryName))
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
        Color(hexString: expense.categoryColor) ?? XPendoTheme.accentTeal
    }
}

private struct HomeBudgetPreviewSection: View {
    let preview: HomeBudgetPreview
    let currencyCode: String

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("home.section.budgetPreview")
                        .font(.headline)
                        .foregroundStyle(XPendoTheme.primaryText)

                    Spacer()

                    budgetStatusPill
                }

                switch preview {
                case .empty:
                    HomeInlineEmptyState(
                        systemImage: "gauge.with.needle",
                        title: AppLocalization.string("home.budgetPreview.empty.title"),
                        description: AppLocalization.string("home.budgetPreview.empty.description")
                    )

                case .tracked(let status):
                    HomeBudgetStatusCard(
                        status: status,
                        currencyCode: currencyCode,
                        accentColor: Color(hexString: status.colorHex) ?? XPendoTheme.freshGreen,
                        footerText: AppLocalization.format("home.budgetPreview.tracked.footer", status.trackedBudgetCount)
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
            Text(AppLocalization.string("budget.status.ready"))
                .foregroundStyle(XPendoTheme.secondaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(XPendoTheme.placeholder.opacity(0.55), in: Capsule())

        case .tracked:
            Text(AppLocalization.string("home.budget.pill.onTrack"))
                .foregroundStyle(XPendoTheme.freshGreen)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(XPendoTheme.freshGreen.opacity(0.12), in: Capsule())

        case .warning:
            Text(AppLocalization.string("home.budget.pill.warning"))
                .foregroundStyle(XPendoTheme.coral)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(XPendoTheme.coral.opacity(0.12), in: Capsule())
        }
    }

    private func warningDescription(for warningCount: Int) -> String {
        if warningCount <= 1 {
            return AppLocalization.string("home.budgetPreview.warning.single")
        }

        return AppLocalization.format("home.budgetPreview.warning.multiple", warningCount)
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
                    Text(CategoryLocalization.localizedName(for: status.categoryName))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(XPendoTheme.primaryText)

                    Text(status.remainingAmount >= 0 ? AppLocalization.string("home.budget.status.remainingAvailable") : AppLocalization.string("home.budget.status.limitExceeded"))
                        .font(.caption)
                        .foregroundStyle(XPendoTheme.secondaryText)
                }
            }

            VStack(spacing: 10) {
                HomeBudgetProgressBar(progress: min(max(status.progress, 0), 1), accentColor: accentColor)

                HStack {
                    Text("budget.spent")
                    Spacer()
                    Text(CurrencyConverter.formatFromTRY(status.spentAmount, to: currencyCode))
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(XPendoTheme.secondaryText)

                HStack {
                    Text(status.remainingAmount >= 0 ? AppLocalization.string("budget.remaining") : AppLocalization.string("budget.overBy"))
                    Spacer()
                    Text(CurrencyConverter.formatFromTRY(abs(status.remainingAmount), to: currencyCode))
                        .foregroundStyle(accentColor)
                }
                .font(.caption.weight(.semibold))

                HStack {
                    Text("budget.limit")
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
