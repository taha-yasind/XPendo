import Foundation
import SwiftData

// Budget modeli, belirli bir category için ay ve yıl bazında limit tutarını saklar.
// Budget ekranı bu modeli günceller; Home, Analytics ve notification akışları bu limitleri okur.
@Model
final class Budget {
    var id: UUID = UUID()
    var category: Category?
    var limitAmount: Double = 0
    var month: Int = 1
    var year: Int = 2026

    init(
        id: UUID = UUID(),
        category: Category,
        limitAmount: Double,
        month: Int,
        year: Int
    ) {
        self.id = id
        self.category = category
        self.limitAmount = limitAmount
        self.month = month
        self.year = year
    }

    // Category silinmiş veya ilişki eksikse UI'nın çökmeden gösterim yapması için fallback alanları sağlanır.
    var categoryID: UUID? {
        category?.id
    }

    var categoryName: String {
        category?.name ?? "Other"
    }

    var categoryIcon: String {
        category?.icon ?? "square.grid.2x2.fill"
    }

    var categoryColor: String {
        category?.color ?? "#8E8E93"
    }
}
