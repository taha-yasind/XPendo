/*
 DOSYA: Expense.swift
 AMAÇ: Tek bir expense entry için SwiftData modelini tanımlar. Amount, category, date, merchant, note ve receipt ile ilgili datayı saklar.
 KULLANAN: AddExpenseViewModel, ExpensesViewModel, HomeViewModel, AnalyticsViewModel ve SwiftData queryleri tarafından kullanılır.
*/
import Foundation
import SwiftData

// Expense modeli, kullanıcının kaydettiği tek bir harcama kaydını temsil eder.
// Add Expense, Expenses, Home, Budget ve Analytics ekranlarının ortak veri kaynağıdır.
@Model
// Shared app behavior veya persisted data sahibi olan reference type tanımlar.
final class Expense {
    var id: UUID = UUID()
    var title: String = ""
    var amount: Double = 0
    var date: Date = Date()
    var category: Category?
    var note: String?
    var createdAt: Date = Date()

    // Bu value’yu çalışmak için ihtiyaç duyduğu data ile hazırlar.
    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        date: Date = .now,
        category: Category,
        note: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
        self.note = note
        self.createdAt = createdAt
    }

    // Category ilişkisi optional olduğu için ekranlarda güvenli fallback değerleri kullanılır.
    var categoryID: UUID? {
        category?.id
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    var categoryName: String {
        category?.name ?? "Other"
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    var categoryIcon: String {
        category?.icon ?? "square.grid.2x2.fill"
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    var categoryColor: String {
        category?.color ?? "#8E8E93"
    }
}
