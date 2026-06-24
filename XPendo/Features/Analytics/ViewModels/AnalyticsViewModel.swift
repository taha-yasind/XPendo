/*
 DOSYA: AnalyticsViewModel.swift
 AMAÇ: Saklanan expense ve budget verilerinden analytics summary değerlerini hesaplar. AnalyticsView için chart-ready değerler hazırlar.
 KULLANAN: AnalyticsView, Expense, Budget ve Category modelleri tarafından kullanılır.
*/
import Foundation

// AnalyticsDashboardData, Analytics ekranındaki chart ve insight verilerini tek yapıda toplar.
struct AnalyticsDashboardData {
    let totalExpenseCount: Int
    let totalSpend: Double
    let categoryTotals: [AnalyticsCategoryTotal]
    let monthlyTotals: [AnalyticsMonthlyTotal]
    let topCategory: AnalyticsCategoryTotal?
    let strongestMonth: AnalyticsMonthlyTotal?
    let trendRangeLabel: String

    // Bu type için odaklı bir davranış parçasını yönetir.
    var averageExpense: Double {
        // Gerekli data eksikse erken çıkış yapar.
        guard totalExpenseCount > 0 else {
            return 0
        }

        return totalSpend / Double(totalExpenseCount)
    }
}

// AnalyticsCategoryTotal, category bazlı toplam harcama ve toplam içindeki pay bilgisini taşır.
struct AnalyticsCategoryTotal: Identifiable {
    let id: UUID
    let name: String
    let icon: String
    let colorHex: String
    let totalAmount: Double
    let expenseCount: Int
    let share: Double
}

// AnalyticsMonthlyTotal, aylık trend chart'ı için ay başlangıcı ve toplam tutarı temsil eder.
struct AnalyticsMonthlyTotal: Identifiable {
    let monthStart: Date
    let totalAmount: Double

    var id: Date { monthStart }
}

// AnalyticsViewModel, Expense listesinden sunuma hazır analytics metrikleri üretir.
// Hesaplama logic'i View'dan ayrıldığı için chart ekranı sadece hazır veriyi çizer.
struct AnalyticsViewModel {
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = AppLocalization.locale
        return calendar
    }
    private let visibleMonthCount = 6

    // Toplam harcama, category dağılımı, aylık trend ve öne çıkan değerler burada hesaplanır.
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

    // Harcamalar category ID'ye göre gruplanır ve büyükten küçüğe sıralanır.
    private func makeCategoryTotals(from expenses: [Expense], totalSpend: Double) -> [AnalyticsCategoryTotal] {
        let categorizedExpenses = expenses.compactMap { expense -> (category: Category, expense: Expense)? in
            // Gerekli data eksikse erken çıkış yapar.
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

    // Son görünen ay aralığı için eksik aylara 0 değer verilerek chart sürekliliği korunur.
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

    // Bu type için odaklı bir davranış parçasını yönetir.
    private func makeTrendRangeLabel(from monthlyTotals: [AnalyticsMonthlyTotal]) -> String {
        // Gerekli data eksikse erken çıkış yapar.
        guard let firstMonth = monthlyTotals.first?.monthStart,
              let lastMonth = monthlyTotals.last?.monthStart else {
            return AppLocalization.string("analytics.trend.lastSixMonths")
        }

        let firstLabel = firstMonth.formatted(.dateTime.month(.abbreviated).year().locale(AppLocalization.locale))
        let lastLabel = lastMonth.formatted(.dateTime.month(.abbreviated).year().locale(AppLocalization.locale))
        return "\(firstLabel) – \(lastLabel)"
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private func startOfMonth(for date: Date) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }
}
