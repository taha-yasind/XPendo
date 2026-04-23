import Foundation
import SwiftData

@Model
final class Category {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String
    var color: String
    var isDefault: Bool

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
