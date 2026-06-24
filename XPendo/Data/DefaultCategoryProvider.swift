/*
 DOSYA: DefaultCategoryProvider.swift
 AMAÇ: App başlarken veya data resetlenirken kullanılan yerleşik expense category listesini sağlar. Category tanımlarının seederlar arasında tekrarlanmasını önler.
 KULLANAN: AppDataSeeder, DemoDataSeeder ve category ile ilgili testler tarafından kullanılır.
*/
import Foundation

// DefaultCategoryDefinition, seed edilecek category için sabit kimlik ve görsel bilgileri taşır.
struct DefaultCategoryDefinition {
    let id: UUID
    let name: String
    let icon: String
    let color: String
}

// DefaultCategoryProvider, uygulamanın başlangıç category listesini merkezi olarak tanımlar.
// Sabit UUID'ler demo data, budget ve expense ilişkilerinin tutarlı kalmasına yardımcı olur.
enum DefaultCategoryProvider {
    static let categories: [DefaultCategoryDefinition] = [
        DefaultCategoryDefinition(id: uuid("A75E3E31-33F8-46FB-942B-2D9F0A61B001"), name: "Food", icon: "fork.knife", color: "#00BFA5"),
        DefaultCategoryDefinition(id: uuid("A75E3E31-33F8-46FB-942B-2D9F0A61B002"), name: "Transport", icon: "car.fill", color: "#27AE60"),
        DefaultCategoryDefinition(id: uuid("A75E3E31-33F8-46FB-942B-2D9F0A61B003"), name: "Shopping", icon: "bag.fill", color: "#E74C3C"),
        DefaultCategoryDefinition(id: uuid("A75E3E31-33F8-46FB-942B-2D9F0A61B004"), name: "Bills", icon: "doc.text.fill", color: "#9B59B6"),
        DefaultCategoryDefinition(id: uuid("A75E3E31-33F8-46FB-942B-2D9F0A61B005"), name: "Entertainment", icon: "gamecontroller.fill", color: "#2ECC71"),
        DefaultCategoryDefinition(id: uuid("A75E3E31-33F8-46FB-942B-2D9F0A61B006"), name: "Health", icon: "heart.fill", color: "#E74C3C"),
        DefaultCategoryDefinition(id: uuid("A75E3E31-33F8-46FB-942B-2D9F0A61B007"), name: "Education", icon: "book.fill", color: "#00BFA5"),
        DefaultCategoryDefinition(id: uuid("A75E3E31-33F8-46FB-942B-2D9F0A61B008"), name: "Other", icon: "square.grid.2x2.fill", color: "#8E8E93")
    ]

    // Bu type için odaklı bir davranış parçasını yönetir.
    private static func uuid(_ value: String) -> UUID {
        UUID(uuidString: value) ?? UUID()
    }
}
