import Foundation
import Observation
import SwiftData

@Observable
final class ExpensesViewModel {
    enum TimeFilter: CaseIterable, Identifiable {
        case all
        case thisMonth
        case lastMonth
        case last3Months
        case last6Months
        case last1Year
        case last2Years

        var id: String {
            switch self {
            case .all:
                return "all"
            case .thisMonth:
                return "thisMonth"
            case .lastMonth:
                return "lastMonth"
            case .last3Months:
                return "last3Months"
            case .last6Months:
                return "last6Months"
            case .last1Year:
                return "last1Year"
            case .last2Years:
                return "last2Years"
            }
        }

        var title: String {
            switch self {
            case .all:
                return AppLocalization.string("expenses.filter.all")
            case .thisMonth:
                return AppLocalization.string("expenses.filter.thisMonth")
            case .lastMonth:
                return AppLocalization.string("expenses.filter.lastMonth")
            case .last3Months:
                return AppLocalization.string("expenses.filter.last3Months")
            case .last6Months:
                return AppLocalization.string("expenses.filter.last6Months")
            case .last1Year:
                return AppLocalization.string("expenses.filter.last1Year")
            case .last2Years:
                return AppLocalization.string("expenses.filter.last2Years")
            }
        }
    }

    var selectedTimeFilter: TimeFilter = .all
    var selectedCategoryID: UUID?
    var expensePendingDelete: Expense?
    var expenseBeingEdited: Expense?

    func filteredExpenses(from expenses: [Expense]) -> [Expense] {
        expenses.filter { expense in
            matchesTimeFilter(expense) && matchesCategoryFilter(expense)
        }
    }

    func categoryFilterTitle(from categories: [Category]) -> String {
        guard let selectedCategoryID else {
            return AppLocalization.string("expenses.filter.allCategories")
        }

        guard let categoryName = categories.first(where: { $0.id == selectedCategoryID })?.name else {
            return AppLocalization.string("expenses.filter.allCategories")
        }

        return CategoryLocalization.localizedName(for: categoryName)
    }

    func selectCategory(_ category: Category?) {
        selectedCategoryID = category?.id
    }

    func resetFilters() {
        selectedTimeFilter = .all
        selectedCategoryID = nil
    }

    func requestEdit(_ expense: Expense) {
        expenseBeingEdited = expense
    }

    func requestDelete(_ expense: Expense) {
        expensePendingDelete = expense
    }

    func deletePendingExpense(in modelContext: ModelContext) throws {
        guard let expensePendingDelete else {
            return
        }

        modelContext.delete(expensePendingDelete)
        try modelContext.save()
        self.expensePendingDelete = nil
    }

    private func matchesTimeFilter(_ expense: Expense) -> Bool {
        let calendar = Calendar.current
        let now = Date()

        switch selectedTimeFilter {
        case .all:
            return true
        case .thisMonth:
            return calendar.isDate(expense.date, equalTo: now, toGranularity: .month)
        case .lastMonth:
            guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: now) else {
                return false
            }
            return calendar.isDate(expense.date, equalTo: previousMonth, toGranularity: .month)
        case .last3Months:
            return isDate(expense.date, inLastMonths: 3, now: now, calendar: calendar)
        case .last6Months:
            return isDate(expense.date, inLastMonths: 6, now: now, calendar: calendar)
        case .last1Year:
            return isDate(expense.date, inLastMonths: 12, now: now, calendar: calendar)
        case .last2Years:
            return isDate(expense.date, inLastMonths: 24, now: now, calendar: calendar)
        }
    }

    private func isDate(
        _ date: Date,
        inLastMonths monthCount: Int,
        now: Date,
        calendar: Calendar
    ) -> Bool {
        guard monthCount > 0 else {
            return false
        }

        let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        guard let rangeStart = calendar.date(byAdding: .month, value: -(monthCount - 1), to: currentMonthStart) else {
            return false
        }

        return date >= rangeStart && date <= now
    }

    private func matchesCategoryFilter(_ expense: Expense) -> Bool {
        guard let selectedCategoryID else {
            return true
        }

        return expense.categoryID == selectedCategoryID
    }
}
