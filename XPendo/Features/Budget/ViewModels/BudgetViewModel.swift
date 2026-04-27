import Foundation
import Observation
import SwiftData

struct BudgetMonthData {
    let trackedBudgetCount: Int
    let overspentCount: Int
    let totalLimit: Double
    let totalSpent: Double
    let totalRemaining: Double
    let budgetStatuses: [BudgetCategoryStatus]

    var totalProgress: Double {
        guard totalLimit > 0 else {
            return 0
        }

        return totalSpent / totalLimit
    }
}

struct BudgetCategoryStatus: Identifiable {
    let id: UUID
    let categoryID: UUID
    let categoryName: String
    let categoryIcon: String
    let colorHex: String
    let limitAmount: Double
    let spentAmount: Double
    let remainingAmount: Double

    var progress: Double {
        guard limitAmount > 0 else {
            return 0
        }

        return spentAmount / limitAmount
    }

    var cappedProgress: Double {
        min(max(progress, 0), 1)
    }

    var isOverBudget: Bool {
        remainingAmount < 0
    }
}

struct BudgetCategoryEntry: Identifiable {
    let id: UUID
    let categoryID: UUID
    let categoryName: String
    let categoryIcon: String
    let colorHex: String
    let limitAmount: Double?
    let spentAmount: Double

    var hasBudget: Bool {
        limitAmount != nil
    }

    var remainingAmount: Double? {
        guard let limitAmount else {
            return nil
        }

        return limitAmount - spentAmount
    }

    var progress: Double {
        guard let limitAmount, limitAmount > 0 else {
            return 0
        }

        return spentAmount / limitAmount
    }

    var cappedProgress: Double {
        min(max(progress, 0), 1)
    }

    var isOverBudget: Bool {
        guard let remainingAmount else {
            return false
        }

        return remainingAmount < 0
    }
}

@Observable
final class BudgetViewModel {
    private let calendar = Calendar.current

    var selectedMonth: Date
    var draftAmountsByCategoryID: [UUID: String] = [:]
    var validationMessage: String?
    private(set) var validationCategoryID: UUID?

    init(now: Date = .now) {
        self.selectedMonth = BudgetViewModel.startOfMonth(for: now)
    }

    var selectedMonthTitle: String {
        selectedMonth.formatted(.dateTime.month(.wide).year())
    }

    func prepare(categories: [Category], budgets: [Budget], displayCurrencyCode: String) {
        draftAmountsByCategoryID = Dictionary(
            uniqueKeysWithValues: categories.map { category in
                let amountText = matchingBudget(for: category.id, in: budgets)
                    .map {
                        formattedAmount(
                            CurrencyConverter.displayAmount(fromTRY: $0.limitAmount, in: displayCurrencyCode)
                        )
                    } ?? ""
                return (category.id, amountText)
            }
        )
        validationCategoryID = nil
        validationMessage = nil
    }

    func moveMonth(by value: Int) {
        guard let movedMonth = calendar.date(byAdding: .month, value: value, to: selectedMonth) else {
            return
        }

        selectedMonth = BudgetViewModel.startOfMonth(for: movedMonth)
    }

    func makeCategoryEntries(
        categories: [Category],
        budgets: [Budget],
        expenses: [Expense]
    ) -> [BudgetCategoryEntry] {
        let monthExpenses = expenses.filter { calendar.isDate($0.date, equalTo: selectedMonth, toGranularity: .month) }
        let spentByCategoryID = Dictionary(grouping: monthExpenses, by: { $0.category.id })
            .mapValues { groupedExpenses in
                groupedExpenses.reduce(0) { partialResult, expense in
                    partialResult + expense.amount
                }
            }

        return categories.map { category in
            let existingBudget = matchingBudget(for: category.id, in: budgets)

            return BudgetCategoryEntry(
                id: category.id,
                categoryID: category.id,
                categoryName: category.name,
                categoryIcon: category.icon,
                colorHex: category.color,
                limitAmount: existingBudget?.limitAmount,
                spentAmount: spentByCategoryID[category.id] ?? 0
            )
        }
    }

    func makeMonthData(budgets: [Budget], expenses: [Expense]) -> BudgetMonthData {
        let monthBudgets = budgetsForSelectedMonth(from: budgets)
        let monthExpenses = expenses.filter { calendar.isDate($0.date, equalTo: selectedMonth, toGranularity: .month) }
        let spentByCategoryID = Dictionary(grouping: monthExpenses, by: { $0.category.id })
            .mapValues { groupedExpenses in
                groupedExpenses.reduce(0) { partialResult, expense in
                    partialResult + expense.amount
                }
            }

        let budgetStatuses = monthBudgets
            .map { budget in
                let spentAmount = spentByCategoryID[budget.category.id] ?? 0

                return BudgetCategoryStatus(
                    id: budget.id,
                    categoryID: budget.category.id,
                    categoryName: budget.category.name,
                    categoryIcon: budget.category.icon,
                    colorHex: budget.category.color,
                    limitAmount: budget.limitAmount,
                    spentAmount: spentAmount,
                    remainingAmount: budget.limitAmount - spentAmount
                )
            }
            .sorted(by: sortBudgetStatuses)

        return BudgetMonthData(
            trackedBudgetCount: budgetStatuses.count,
            overspentCount: budgetStatuses.filter(\.isOverBudget).count,
            totalLimit: budgetStatuses.reduce(0) { $0 + $1.limitAmount },
            totalSpent: budgetStatuses.reduce(0) { $0 + $1.spentAmount },
            totalRemaining: budgetStatuses.reduce(0) { $0 + $1.remainingAmount },
            budgetStatuses: budgetStatuses
        )
    }

    func draftAmount(for categoryID: UUID) -> String {
        draftAmountsByCategoryID[categoryID] ?? ""
    }

    func updateDraftAmount(_ text: String, for categoryID: UUID) {
        draftAmountsByCategoryID[categoryID] = text

        if validationCategoryID == categoryID {
            validationCategoryID = nil
            validationMessage = nil
        }
    }

    func saveButtonTitle(for categoryID: UUID, budgets: [Budget]) -> String {
        matchingBudget(for: categoryID, in: budgets) == nil ? "Save" : "Update"
    }

    func isResetEnabled(for categoryID: UUID, budgets: [Budget]) -> Bool {
        if matchingBudget(for: categoryID, in: budgets) != nil {
            return true
        }

        let draftAmount = draftAmount(for: categoryID).trimmingCharacters(in: .whitespacesAndNewlines)
        return !draftAmount.isEmpty
    }

    func validationMessage(for categoryID: UUID) -> String? {
        guard validationCategoryID == categoryID else {
            return nil
        }

        return validationMessage
    }

    func saveBudget(
        for category: Category,
        in modelContext: ModelContext,
        budgets: [Budget],
        inputCurrencyCode: String
    ) throws {
        validationMessage = nil
        validationCategoryID = nil

        guard let amount = parsedAmount(from: draftAmount(for: category.id)), amount > 0 else {
            validationCategoryID = category.id
            validationMessage = "Enter an amount greater than zero for this category."
            return
        }

        let amountInTRY = CurrencyConverter.convertToTRY(amount, from: inputCurrencyCode)

        if let existingBudget = matchingBudget(for: category.id, in: budgets) {
            existingBudget.limitAmount = amountInTRY
        } else {
            let newBudget = Budget(
                category: category,
                limitAmount: amountInTRY,
                month: calendar.component(.month, from: selectedMonth),
                year: calendar.component(.year, from: selectedMonth)
            )

            modelContext.insert(newBudget)
        }

        try modelContext.save()
        draftAmountsByCategoryID[category.id] = formattedAmount(amount)
    }

    func resetBudget(
        for categoryID: UUID,
        in modelContext: ModelContext,
        budgets: [Budget]
    ) throws {
        if let existingBudget = matchingBudget(for: categoryID, in: budgets) {
            modelContext.delete(existingBudget)
            try modelContext.save()
        }

        draftAmountsByCategoryID[categoryID] = ""

        if validationCategoryID == categoryID {
            validationCategoryID = nil
            validationMessage = nil
        }
    }

    private func budgetsForSelectedMonth(from budgets: [Budget]) -> [Budget] {
        let month = calendar.component(.month, from: selectedMonth)
        let year = calendar.component(.year, from: selectedMonth)

        return budgets.filter { $0.month == month && $0.year == year }
    }

    private func matchingBudget(for categoryID: UUID, in budgets: [Budget]) -> Budget? {
        budgetsForSelectedMonth(from: budgets).first(where: { $0.category.id == categoryID })
    }

    private func parsedAmount(from text: String) -> Double? {
        let normalizedText = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        return Double(normalizedText)
    }

    private func formattedAmount(_ amount: Double) -> String {
        BudgetViewModel.amountFormatter.string(from: NSNumber(value: amount)) ?? String(amount)
    }

    private func sortBudgetStatuses(_ lhs: BudgetCategoryStatus, _ rhs: BudgetCategoryStatus) -> Bool {
        if lhs.isOverBudget != rhs.isOverBudget {
            return lhs.isOverBudget && !rhs.isOverBudget
        }

        if lhs.progress != rhs.progress {
            return lhs.progress > rhs.progress
        }

        return lhs.categoryName < rhs.categoryName
    }

    private static func startOfMonth(for date: Date) -> Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: date)) ?? date
    }

    private static let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }()
}
