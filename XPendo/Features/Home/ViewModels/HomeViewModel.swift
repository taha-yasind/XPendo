import Foundation

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

struct HomeViewModel {
    private let calendar = Calendar.current
    private let recentExpenseLimit = 4

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

    private func makeTopCategory(from expenses: [Expense]) -> HomeTopCategorySummary? {
        let groupedExpenses = Dictionary(grouping: expenses, by: { $0.category.id })

        let categoryTotals = Array(groupedExpenses.values).map { groupedExpenses in
            let firstExpense = groupedExpenses[0]
            return HomeTopCategorySummary(
                name: firstExpense.category.name,
                icon: firstExpense.category.icon,
                colorHex: firstExpense.category.color,
                totalAmount: totalAmount(of: groupedExpenses)
            )
        }

        return categoryTotals.max(by: { $0.totalAmount < $1.totalAmount })
    }

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

        let spentByCategoryID = Dictionary(grouping: monthExpenses, by: { $0.category.id })
            .mapValues { expenses in
                totalAmount(of: expenses)
            }

        let budgetStatuses = currentMonthBudgets.map { budget in
            let spentAmount = spentByCategoryID[budget.category.id] ?? 0

            return HomeBudgetStatus(
                categoryName: budget.category.name,
                categoryIcon: budget.category.icon,
                colorHex: budget.category.color,
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
