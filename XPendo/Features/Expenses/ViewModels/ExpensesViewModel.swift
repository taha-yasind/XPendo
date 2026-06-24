/*
 DOSYA: ExpensesViewModel.swift
 AMAÇ: Expense listesi için search, filtering, grouping ve delete davranışını yönetir. ExpensesView için expense datasını hazırlar.
 KULLANAN: ExpensesView, ExpenseRowCard ve SwiftData expense queryleri tarafından kullanılır.
*/
import Foundation
import Observation
import SwiftData

// ExpensesViewModel, harcama listesi için filtre, edit ve delete state'ini yönetir.
// SwiftData sorgusundan gelen listeyi değiştirmez; sadece görünüm için filtrelenmiş sonuç üretir.
@Observable
// Screen state ve user actionları SwiftUI layout’tan ayrı tutar.
final class ExpensesViewModel {
    // TimeFilter, kullanıcıya sunulan tarih aralığı seçeneklerini temsil eder.
    enum TimeFilter: CaseIterable, Identifiable {
        case all
        case thisMonth
        case lastMonth
        case last3Months
        case last6Months
        case last1Year
        case last2Years

        // Bu type için odaklı bir davranış parçasını yönetir.
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

        // Bu type için odaklı bir davranış parçasını yönetir.
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

    // Seçili time/category filtreleri birlikte uygulanarak liste görünümü hazırlanır.
    func filteredExpenses(from expenses: [Expense]) -> [Expense] {
        expenses.filter { expense in
            matchesTimeFilter(expense) && matchesCategoryFilter(expense)
        }
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    func categoryFilterTitle(from categories: [Category]) -> String {
        // Gerekli data eksikse erken çıkış yapar.
        guard let selectedCategoryID else {
            return AppLocalization.string("expenses.filter.allCategories")
        }

        // Gerekli data eksikse erken çıkış yapar.
        guard let categoryName = categories.first(where: { $0.id == selectedCategoryID })?.name else {
            return AppLocalization.string("expenses.filter.allCategories")
        }

        return CategoryLocalization.localizedName(for: categoryName)
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    func selectCategory(_ category: Category?) {
        selectedCategoryID = category?.id
    }

    // Bu state’i default değerlerine geri döndürür.
    func resetFilters() {
        selectedTimeFilter = .all
        selectedCategoryID = nil
    }

    // Edit isteği sheet state'ine aktarılır; gerçek güncelleme AddExpenseView üzerinden yapılır.
    func requestEdit(_ expense: Expense) {
        expenseBeingEdited = expense
    }

    // Delete isteği önce onay sheet'ine taşınır; kayıt hemen silinmez.
    func requestDelete(_ expense: Expense) {
        expensePendingDelete = expense
    }

    // Kullanıcı onayladıktan sonra pending Expense ModelContext'ten silinir ve kaydedilir.
    func deletePendingExpense(in modelContext: ModelContext) throws {
        // Gerekli data eksikse erken çıkış yapar.
        guard let expensePendingDelete else {
            return
        }

        modelContext.delete(expensePendingDelete)
        try modelContext.save()
        self.expensePendingDelete = nil
    }

    // Tarih filtresi Calendar ile hesaplanır; UI sadece TimeFilter seçimini değiştirir.
    private func matchesTimeFilter(_ expense: Expense) -> Bool {
        let calendar = Calendar.current
        let now = Date()

        switch selectedTimeFilter {
        case .all:
            return true
        case .thisMonth:
            return calendar.isDate(expense.date, equalTo: now, toGranularity: .month)
        case .lastMonth:
            // Gerekli data eksikse erken çıkış yapar.
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

    // Bu type için odaklı bir davranış parçasını yönetir.
    private func isDate(
        _ date: Date,
        inLastMonths monthCount: Int,
        now: Date,
        calendar: Calendar
    ) -> Bool {
        // Gerekli data eksikse erken çıkış yapar.
        guard monthCount > 0 else {
            return false
        }

        let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        // Gerekli data eksikse erken çıkış yapar.
        guard let rangeStart = calendar.date(byAdding: .month, value: -(monthCount - 1), to: currentMonthStart) else {
            return false
        }

        return date >= rangeStart && date <= now
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private func matchesCategoryFilter(_ expense: Expense) -> Bool {
        // Gerekli data eksikse erken çıkış yapar.
        guard let selectedCategoryID else {
            return true
        }

        return expense.categoryID == selectedCategoryID
    }
}
