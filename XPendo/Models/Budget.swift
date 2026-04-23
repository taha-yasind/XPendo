import Foundation
import SwiftData

@Model
final class Budget {
    @Attribute(.unique) var id: UUID
    var category: Category
    var limitAmount: Double
    var month: Int
    var year: Int

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
}
