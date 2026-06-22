import Foundation
import SwiftData

// Category modeli, harcamaları sınıflandırmak için kullanılan SwiftData varlığıdır.
// DefaultCategoryProvider tarafından seed edilir ve expense/budget kayıtlarıyla ilişkilendirilir.
@Model
final class Category {
    var id: UUID = UUID()
    var name: String = ""
    var icon: String = "tag.fill"
    var color: String = "#8E8E93"
    var isDefault: Bool = false

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
