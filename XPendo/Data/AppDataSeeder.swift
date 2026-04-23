import Foundation
import SwiftData

enum AppDataSeeder {
    static func seedIfNeeded(in modelContext: ModelContext) throws {
        try seedDefaultCategories(in: modelContext)
        try seedAppSettings(in: modelContext)

        if modelContext.hasChanges {
            try modelContext.save()
        }
    }

    private static func seedDefaultCategories(in modelContext: ModelContext) throws {
        let existingCategories = try modelContext.fetch(FetchDescriptor<Category>())
        let existingNames = Set(existingCategories.map(\.name))

        for categoryDefinition in DefaultCategoryProvider.categories where !existingNames.contains(categoryDefinition.name) {
            let category = Category(
                name: categoryDefinition.name,
                icon: categoryDefinition.icon,
                color: categoryDefinition.color,
                isDefault: true
            )

            modelContext.insert(category)
        }
    }

    private static func seedAppSettings(in modelContext: ModelContext) throws {
        let existingSettings = try modelContext.fetch(FetchDescriptor<AppSettings>())

        if existingSettings.isEmpty {
            let settings = AppSettings(currencyCode: defaultCurrencyCode)
            modelContext.insert(settings)
        }
    }

    private static var defaultCurrencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }
}
