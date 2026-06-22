import Charts
import SwiftData
import SwiftUI

// AnalyticsView, harcama verilerini chart ve kısa insight kartları olarak gösterir.
// Swift Charts kullanır; hesaplama verileri AnalyticsViewModel tarafından hazırlanır.
struct AnalyticsView: View {
    @Query(
        sort: [
            SortDescriptor(\Expense.date, order: .reverse),
            SortDescriptor(\Expense.createdAt, order: .reverse)
        ]
    ) private var expenses: [Expense]
    @Query private var settings: [AppSettings]

    private let viewModel = AnalyticsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AnalyticsHeader()

                if expenses.isEmpty {
                    AnalyticsEmptyState()
                } else {
                    AnalyticsInsightsSection(
                        data: analyticsData,
                        currencyCode: currencyCode
                    )

                    AnalyticsCategoryChartSection(
                        categories: analyticsData.categoryTotals,
                        currencyCode: currencyCode
                    )

                    AnalyticsMonthlyTrendSection(
                        monthlyTotals: analyticsData.monthlyTotals,
                        trendRangeLabel: analyticsData.trendRangeLabel,
                        strongestMonth: analyticsData.strongestMonth,
                        currencyCode: currencyCode
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 130)
        }
        .background(XPendoTheme.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    // Analytics hesaplaması, güncel SwiftData Expense listesi üzerinden yapılır.
    private var analyticsData: AnalyticsDashboardData {
        viewModel.makeDashboardData(expenses: expenses)
    }

    private var currencyCode: String {
        CurrencyConverter.supportedCurrencyCode(from: settings.first?.currencyCode)
    }
}

#Preview {
    NavigationStack {
        AnalyticsView()
            .modelContainer(XPendoModelContainer.shared)
    }
    .background(XPendoTheme.background)
}

private struct AnalyticsHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(AppLocalization.string("analytics.header.title"))
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(XPendoTheme.primaryText)

            Text(AppLocalization.string("analytics.header.subtitle"))
                .font(.subheadline)
                .foregroundStyle(XPendoTheme.secondaryText)
        }
    }
}

// AnalyticsInsightsSection, toplam harcama, top category ve en güçlü ay gibi özetleri gösterir.
private struct AnalyticsInsightsSection: View {
    let data: AnalyticsDashboardData
    let currencyCode: String

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 18) {
                Text(AppLocalization.string("analytics.section.quickInsights"))
                    .font(.headline)
                    .foregroundStyle(XPendoTheme.primaryText)

                VStack(spacing: 12) {
                    AnalyticsInsightRow(
                        title: AppLocalization.string("analytics.insight.recordedSpend"),
                        value: CurrencyConverter.formatFromTRY(data.totalSpend, to: currencyCode),
                        detail: AppLocalization.format("analytics.insight.recordedSpend.detail", data.totalExpenseCount),
                        accentColor: XPendoTheme.accentTeal,
                        systemImage: "creditcard.fill"
                    )

                    AnalyticsInsightRow(
                        title: AppLocalization.string("analytics.insight.topCategory"),
                        value: data.topCategory.map { CategoryLocalization.localizedName(for: $0.name) } ?? AppLocalization.string("analytics.insight.topCategory.emptyValue"),
                        detail: topCategoryDetail,
                        accentColor: topCategoryColor,
                        systemImage: data.topCategory?.icon ?? "square.grid.2x2.fill"
                    )

                    AnalyticsInsightRow(
                        title: AppLocalization.string("analytics.insight.strongestMonth"),
                        value: strongestMonthValue,
                        detail: strongestMonthDetail,
                        accentColor: XPendoTheme.softPurple,
                        systemImage: "chart.line.uptrend.xyaxis"
                    )
                }
            }
        }
    }

    private var topCategoryDetail: String {
        guard let topCategory = data.topCategory else {
            return AppLocalization.string("analytics.insight.topCategory.emptyDetail")
        }

        return AppLocalization.format("analytics.insight.topCategory.shareDetail", shareText(for: topCategory.share), CurrencyConverter.formatFromTRY(topCategory.totalAmount, to: currencyCode))
    }

    private var strongestMonthValue: String {
        guard let strongestMonth = data.strongestMonth else {
            return AppLocalization.string("analytics.insight.strongestMonth.emptyValue")
        }

        return strongestMonth.monthStart.formatted(.dateTime.month(.wide).year())
    }

    private var strongestMonthDetail: String {
        guard let strongestMonth = data.strongestMonth else {
            return AppLocalization.string("analytics.insight.strongestMonth.emptyDetail")
        }

        return CurrencyConverter.formatFromTRY(strongestMonth.totalAmount, to: currencyCode)
    }

    private var topCategoryColor: Color {
        guard let colorHex = data.topCategory?.colorHex else {
            return XPendoTheme.housingGreen
        }

        return Color(hexString: colorHex) ?? XPendoTheme.housingGreen
    }

    private func shareText(for share: Double) -> String {
        "\(Int((share * 100).rounded()))%"
    }
}

private struct AnalyticsInsightRow: View {
    let title: String
    let value: String
    let detail: String
    let accentColor: Color
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(accentColor.opacity(0.12))
                .frame(width: 46, height: 46)
                .overlay {
                    Image(systemName: systemImage)
                        .font(.headline)
                        .foregroundStyle(accentColor)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(XPendoTheme.secondaryText)

                Text(value)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(XPendoTheme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(detail)
                    .font(.caption)
                    .foregroundStyle(XPendoTheme.secondaryText)
            }

            Spacer()
        }
        .padding(14)
        .background(XPendoTheme.inputBackground, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

// AnalyticsCategoryChartSection, category toplamlarını horizontal bar chart olarak sunar.
private struct AnalyticsCategoryChartSection: View {
    let categories: [AnalyticsCategoryTotal]
    let currencyCode: String

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(AppLocalization.string("analytics.section.categoryBreakdown"))
                            .font(.headline)
                            .foregroundStyle(XPendoTheme.primaryText)

                        Text(AppLocalization.string("analytics.section.categoryBreakdown.subtitle"))
                            .font(.subheadline)
                            .foregroundStyle(XPendoTheme.secondaryText)
                    }

                    Spacer()

                    Text(AppLocalization.format("analytics.category.count", categories.count))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(XPendoTheme.accentTeal)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(XPendoTheme.accentTeal.opacity(0.12), in: Capsule())
                }

                Chart(categories) { category in
                    BarMark(
                        x: .value("Amount", category.totalAmount),
                        y: .value("Category", category.name)
                    )
                    .foregroundStyle(categoryColor(for: category))
                    .cornerRadius(10)
                    .annotation(position: .trailing, alignment: .center) {
                        Text(CurrencyConverter.formatFromTRY(category.totalAmount, to: currencyCode))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(XPendoTheme.secondaryText)
                    }
                }
                .frame(height: max(240, CGFloat(categories.count) * 44))
                .chartLegend(.hidden)
                .chartXAxis(.hidden)
                .chartXScale(domain: 0...chartDomainUpperBound)
                .chartPlotStyle { content in
                    content
                        .background(XPendoTheme.inputBackground.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
            }
        }
    }

    private func categoryColor(for category: AnalyticsCategoryTotal) -> Color {
        Color(hexString: category.colorHex) ?? XPendoTheme.accentTeal
    }

    private var chartDomainUpperBound: Double {
        let maxValue = categories.map(\.totalAmount).max() ?? 0
        return max(maxValue * 1.2, 1)
    }
}

// AnalyticsMonthlyTrendSection, son ayların toplam harcama trendini area/line chart ile gösterir.
private struct AnalyticsMonthlyTrendSection: View {
    let monthlyTotals: [AnalyticsMonthlyTotal]
    let trendRangeLabel: String
    let strongestMonth: AnalyticsMonthlyTotal?
    let currencyCode: String

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(AppLocalization.string("analytics.section.monthlyTrend"))
                            .font(.headline)
                            .foregroundStyle(XPendoTheme.primaryText)

                        Text(AppLocalization.string("analytics.section.monthlyTrend.subtitle"))
                            .font(.subheadline)
                            .foregroundStyle(XPendoTheme.secondaryText)
                    }

                    Spacer()

                    Text(trendRangeLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(XPendoTheme.secondaryText)
                }

                Chart {
                    ForEach(monthlyTotals) { month in
                        AreaMark(
                            x: .value("Month", month.monthStart),
                            y: .value("Amount", month.totalAmount)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    XPendoTheme.accentTeal.opacity(0.24),
                                    XPendoTheme.accentTeal.opacity(0.04)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                        LineMark(
                            x: .value("Month", month.monthStart),
                            y: .value("Amount", month.totalAmount)
                        )
                        .foregroundStyle(XPendoTheme.accentTeal)
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                        PointMark(
                            x: .value("Month", month.monthStart),
                            y: .value("Amount", month.totalAmount)
                        )
                        .foregroundStyle(XPendoTheme.accentTeal)
                        .symbolSize(60)
                    }
                }
                .frame(height: 250)
                .chartLegend(.hidden)
                .chartXAxis {
                    AxisMarks(values: monthlyTotals.map(\.monthStart)) { value in
                        AxisTick()
                            .foregroundStyle(XPendoTheme.placeholder.opacity(0.8))

                        AxisValueLabel {
                            if let monthDate = value.as(Date.self) {
                                Text(monthDate, format: .dateTime.month(.abbreviated))
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let rawAmount = value.as(Double.self) {
                                Text(CurrencyConverter.formatFromTRY(rawAmount, to: currencyCode))
                            }
                        }
                    }
                }
                .chartPlotStyle { content in
                    content
                        .background(XPendoTheme.inputBackground.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                }

                if let strongestMonth {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(XPendoTheme.softPurple)

                        Text(AppLocalization.format("analytics.trend.strongestMonthDetail", strongestMonth.monthStart.formatted(.dateTime.month(.wide).year()), CurrencyConverter.formatFromTRY(strongestMonth.totalAmount, to: currencyCode)))
                            .font(.subheadline)
                            .foregroundStyle(XPendoTheme.secondaryText)
                    }
                    .padding(14)
                    .background(XPendoTheme.softPurple.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
            }
        }
    }
}

private struct AnalyticsEmptyState: View {
    var body: some View {
        SurfaceCard {
            StateMessageContent(
                systemImage: "chart.bar.xaxis",
                title: AppLocalization.string("analytics.empty.title"),
                description: AppLocalization.string("analytics.empty.description"),
                accentColor: XPendoTheme.accentTeal
            )
        }
    }
}
