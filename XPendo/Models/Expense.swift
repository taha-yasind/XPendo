import Foundation
import SwiftData

@Model
final class Expense {
    @Attribute(.unique) var id: UUID
    var title: String
    var amount: Double
    var date: Date
    var category: Category
    var note: String?
    var createdAt: Date

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
}
