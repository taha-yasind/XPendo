/*
 DOSYA: Category.swift
 AMAÇ: Expense categoryleri için SwiftData modelini tanımlar. Category kayıtları UI genelinde kullanılan name, color ve icon bilgilerini sağlar.
 KULLANAN: Expense, DefaultCategoryProvider, AddExpenseViewModel ve list/chart viewleri tarafından kullanılır.
*/
import Foundation
import SwiftData

// Category modeli, harcamaları sınıflandırmak için kullanılan SwiftData varlığıdır.
// DefaultCategoryProvider tarafından seed edilir ve expense/budget kayıtlarıyla ilişkilendirilir.
@Model
// Shared app behavior veya persisted data sahibi olan reference type tanımlar.
final class Category {
    var id: UUID = UUID()
    var name: String = ""
    var icon: String = "tag.fill"
    var color: String = "#8E8E93"
    var isDefault: Bool = false

    // Bu value’yu çalışmak için ihtiyaç duyduğu data ile hazırlar.
    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        color: String,
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.isDefault = isDefault
    }
}
