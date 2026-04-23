import Foundation

struct DefaultCategoryDefinition {
    let name: String
    let icon: String
    let color: String
}

enum DefaultCategoryProvider {
    static let categories: [DefaultCategoryDefinition] = [
        DefaultCategoryDefinition(name: "Food", icon: "fork.knife", color: "#00BFA5"),
        DefaultCategoryDefinition(name: "Transport", icon: "car.fill", color: "#27AE60"),
        DefaultCategoryDefinition(name: "Shopping", icon: "bag.fill", color: "#E74C3C"),
        DefaultCategoryDefinition(name: "Bills", icon: "doc.text.fill", color: "#9B59B6"),
        DefaultCategoryDefinition(name: "Entertainment", icon: "gamecontroller.fill", color: "#2ECC71"),
        DefaultCategoryDefinition(name: "Health", icon: "heart.fill", color: "#E74C3C"),
        DefaultCategoryDefinition(name: "Education", icon: "book.fill", color: "#00BFA5"),
        DefaultCategoryDefinition(name: "Other", icon: "square.grid.2x2.fill", color: "#8E8E93")
    ]
}
