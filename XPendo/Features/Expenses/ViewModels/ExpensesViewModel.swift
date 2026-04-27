import Foundation
import Observation
import SwiftData

@Observable
final class ExpensesViewModel {
    enum TimeFilter: CaseIterable, Identifiable {
        case all
        case thisMonth

        var id: String {
            switch self {
            case .all:
                return "all"
            case .thisMonth:
                return "thisMonth"
            }
        }

        var title: String {
            switch self {
            case .all:
                return AppLocalization.string("expenses.filter.all")
            case .thisMonth:
                return AppLocalization.string("expenses.filter.thisMonth")
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
        switch selectedTimeFilter {
        case .all:
            return true
        case .thisMonth:
            return Calendar.current.isDate(expense.date, equalTo: .now, toGranularity: .month)
        }
    }

    private func matchesCategoryFilter(_ expense: Expense) -> Bool {
        guard let selectedCategoryID else {
            return true
        }

        return expense.category.id == selectedCategoryID
    }
}
