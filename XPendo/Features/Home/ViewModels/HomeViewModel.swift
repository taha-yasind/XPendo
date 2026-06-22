import Foundation

// HomeDashboardData, Home ekranında gösterilen özet metrikleri tek modelde toplar.
struct HomeDashboardData {
    let monthLabel: String
    let todayTotal: Double
    let todayExpenseCount: Int
    let monthTotal: Double
    let monthExpenseCount: Int
    let recentExpenses: [Expense]
    let topCategory: HomeTopCategorySummary?
    let budgetPreview: HomeBudgetPreview
}

struct HomeTopCategorySummary {
    let name: String
    let icon: String
    let colorHex: String
    let totalAmount: Double
}

enum HomeBudgetPreview {
    case empty
    case tracked(HomeBudgetStatus)
    case warning(HomeBudgetStatus)
}

struct HomeBudgetStatus {
    let categoryName: String
    let categoryIcon: String
    let colorHex: String
    let spentAmount: Double
    let limitAmount: Double
    let remainingAmount: Double
    let trackedBudgetCount: Int
    let warningCount: Int

    var progress: Double {
        guard limitAmount > 0 else {
            return 0
        }

        return spentAmount / limitAmount
    }
}

// HomeViewModel, SwiftData'dan gelen Expense ve Budget listelerini dashboard verisine dönüştürür.
// UI kodu hesaplama detaylarını bilmeden hazır özet verileri kullanır.
struct HomeViewModel {
    private let calendar = Calendar.current
    private let recentExpenseLimit = 4

    // Home ekranı için bugün, bu ay, son harcamalar, top category ve budget preview hesaplanır.
    func makeDashboardData(
        expenses: [Expense],
        budgets: [Budget],
        now: Date = .now
    ) -> HomeDashboardData {
        let todayExpenses = expenses.filter { calendar.isDate($0.date, inSameDayAs: now) }
        let monthExpenses = expenses.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
        let recentExpenses = Array(expenses.prefix(recentExpenseLimit))
        let topCategory = makeTopCategory(from: monthExpenses)
        let budgetPreview = makeBudgetPreview(from: monthExpenses, budgets: budgets, now: now)

        return HomeDashboardData(
            monthLabel: now.formatted(.dateTime.month(.wide)),
            todayTotal: totalAmount(of: todayExpenses),
            todayExpenseCount: todayExpenses.count,
            monthTotal: totalAmount(of: monthExpenses),
            monthExpenseCount: monthExpenses.count,
            recentExpenses: recentExpenses,
            topCategory: topCategory,
            budgetPreview: budgetPreview
        )
    }

    // Bu ayın harcamaları category bazında gruplanır ve en yüksek toplamlı category seçilir.
    private func makeTopCategory(from expenses: [Expense]) -> HomeTopCategorySummary? {
        let categorizedExpenses = expenses.compactMap { expense -> (category: Category, expense: Expense)? in
            guard let category = expense.category else {
                return nil
            }

            return (category, expense)
        }
        let groupedExpenses = Dictionary(grouping: categorizedExpenses, by: { $0.category.id })

        let categoryTotals = Array(groupedExpenses.values).map { groupedExpenses in
            let firstItem = groupedExpenses[0]
            return HomeTopCategorySummary(
                name: firstItem.category.name,
                icon: firstItem.category.icon,
                colorHex: firstItem.category.color,
                totalAmount: totalAmount(of: groupedExpenses.map(\.expense))
            )
        }

        return categoryTotals.max(by: { $0.totalAmount < $1.totalAmount })
    }

    // Budget preview, mevcut ay budget'larında aşım varsa warning; yoksa en aktif budget durumunu üretir.
    private func makeBudgetPreview(
        from monthExpenses: [Expense],
        budgets: [Budget],
        now: Date
    ) -> HomeBudgetPreview {
        let month = calendar.component(.month, from: now)
        let year = calendar.component(.year, from: now)
        let currentMonthBudgets = budgets.filter { $0.month == month && $0.year == year }

        guard !currentMonthBudgets.isEmpty else {
            return .empty
        }

        let spentByCategoryID = Dictionary(grouping: monthExpenses, by: { $0.categoryID })
            .mapValues { expenses in
                totalAmount(of: expenses)
            }

        let budgetStatuses = currentMonthBudgets.compactMap { budget -> HomeBudgetStatus? in
            guard let categoryID = budget.categoryID else {
                return nil
            }

            let spentAmount = spentByCategoryID[Optional(categoryID)] ?? 0

            return HomeBudgetStatus(
                categoryName: budget.categoryName,
                categoryIcon: budget.categoryIcon,
                colorHex: budget.categoryColor,
                spentAmount: spentAmount,
                limitAmount: budget.limitAmount,
                remainingAmount: budget.limitAmount - spentAmount,
                trackedBudgetCount: currentMonthBudgets.count,
                warningCount: 0
            )
        }

        let warningStatuses = budgetStatuses.filter { $0.limitAmount > 0 && $0.spentAmount > $0.limitAmount }

        if let highestWarning = warningStatuses.max(by: { overAmount(of: $0) < overAmount(of: $1) }) {
            return .warning(
                HomeBudgetStatus(
                    categoryName: highestWarning.categoryName,
                    categoryIcon: highestWarning.categoryIcon,
                    colorHex: highestWarning.colorHex,
                    spentAmount: highestWarning.spentAmount,
                    limitAmount: highestWarning.limitAmount,
                    remainingAmount: highestWarning.remainingAmount,
                    trackedBudgetCount: highestWarning.trackedBudgetCount,
                    warningCount: warningStatuses.count
                )
            )
        }

        guard let mostActiveBudget = budgetStatuses.max(by: { $0.progress < $1.progress }) else {
            return .empty
        }

        return .tracked(mostActiveBudget)
    }

    private func totalAmount(of expenses: [Expense]) -> Double {
        expenses.reduce(0) { partialResult, expense in
            partialResult + expense.amount
        }
    }

    private func overAmount(of status: HomeBudgetStatus) -> Double {
        status.spentAmount - status.limitAmount
    }
}
