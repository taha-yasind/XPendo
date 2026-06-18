import Foundation
import SwiftData

@Model
final class Expense {
    var id: UUID = UUID()
    var title: String = ""
    var amount: Double = 0
    var date: Date = Date()
    var category: Category?
    var note: String?
    var createdAt: Date = Date()

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
