import Foundation

struct AnalyticsDashboardData {
    let totalExpenseCount: Int
    let totalSpend: Double
    let categoryTotals: [AnalyticsCategoryTotal]
    let monthlyTotals: [AnalyticsMonthlyTotal]
    let topCategory: AnalyticsCategoryTotal?
    let strongestMonth: AnalyticsMonthlyTotal?
    let trendRangeLabel: String

    var averageExpense: Double {
        guard totalExpenseCount > 0 else {
            return 0
        }

        return totalSpend / Double(totalExpenseCount)
    }
}

struct AnalyticsCategoryTotal: Identifiable {
    let id: UUID
    let name: String
    let icon: String
    let colorHex: String
    let totalAmount: Double
    let expenseCount: Int
    let share: Double
}

struct AnalyticsMonthlyTotal: Identifiable {
    let monthStart: Date
    let totalAmount: Double

    var id: Date { monthStart }
}

struct AnalyticsViewModel {
    private let calendar = Calendar.current
    private let visibleMonthCount = 6

    func makeDashboardData(expenses: [Expense], now: Date = .now) -> AnalyticsDashboardData {
        let totalSpend = expenses.reduce(0) { partialResult, expense in
            partialResult + expense.amount
        }

        let categoryTotals = makeCategoryTotals(from: expenses, totalSpend: totalSpend)
        let anchorDate = expenses.map(\.date).max() ?? now
        let monthlyTotals = makeMonthlyTotals(from: expenses, anchorDate: anchorDate)

        return AnalyticsDashboardData(
            totalExpenseCount: expenses.count,
            totalSpend: totalSpend,
            categoryTotals: categoryTotals,
            monthlyTotals: monthlyTotals,
            topCategory: categoryTotals.first,
            strongestMonth: monthlyTotals.max(by: { $0.totalAmount < $1.totalAmount }),
            trendRangeLabel: makeTrendRangeLabel(from: monthlyTotals)
        )
    }

    private func makeCategoryTotals(from expenses: [Expense], totalSpend: Double) -> [AnalyticsCategoryTotal] {
        let categorizedExpenses = expenses.compactMap { expense -> (category: Category, expense: Expense)? in
            guard let category = expense.category else {
                return nil
            }

            return (category, expense)
        }
        let groupedExpenses = Dictionary(grouping: categorizedExpenses, by: { $0.category.id })

        return groupedExpenses.values
            .map { groupedExpenses in
                let firstItem = groupedExpenses[0]
                let categoryTotal = groupedExpenses.reduce(0) { partialResult, item in
                    partialResult + item.expense.amount
                }

                return AnalyticsCategoryTotal(
                    id: firstItem.category.id,
                    name: CategoryLocalization.localizedName(for: firstItem.category.name),
                    icon: firstItem.category.icon,
                    colorHex: firstItem.category.color,
                    totalAmount: categoryTotal,
                    expenseCount: groupedExpenses.count,
                    share: totalSpend > 0 ? categoryTotal / totalSpend : 0
                )
            }
            .sorted { $0.totalAmount > $1.totalAmount }
    }

    private func makeMonthlyTotals(from expenses: [Expense], anchorDate: Date) -> [AnalyticsMonthlyTotal] {
        let anchorMonth = startOfMonth(for: anchorDate)
        let visibleMonths = (0..<visibleMonthCount).compactMap { index in
            calendar.date(byAdding: .month, value: index - (visibleMonthCount - 1), to: anchorMonth)
        }

        let totalsByMonth = Dictionary(grouping: expenses, by: { startOfMonth(for: $0.date) })
            .mapValues { groupedExpenses in
                groupedExpenses.reduce(0) { partialResult, expense in
                    partialResult + expense.amount
                }
            }

        return visibleMonths.map { monthStart in
            AnalyticsMonthlyTotal(
                monthStart: monthStart,
                totalAmount: totalsByMonth[monthStart] ?? 0
            )
        }
    }

    private func makeTrendRangeLabel(from monthlyTotals: [AnalyticsMonthlyTotal]) -> String {
        guard let firstMonth = monthlyTotals.first?.monthStart,
              let lastMonth = monthlyTotals.last?.monthStart else {
            return AppLocalization.string("analytics.trend.lastSixMonths")
        }

        let firstLabel = firstMonth.formatted(.dateTime.month(.abbreviated).year())
        let lastLabel = lastMonth.formatted(.dateTime.month(.abbreviated).year())
        return "\(firstLabel) – \(lastLabel)"
    }

    private func startOfMonth(for date: Date) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }
}
