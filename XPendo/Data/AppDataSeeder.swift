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
            let settings = AppSettings(
                currencyCode: defaultCurrencyCode,
                preferredThemeCode: defaultThemeCode
            )
            modelContext.insert(settings)
            return
        }

        for settings in existingSettings {
            if settings.preferredThemeCode?.isEmpty != false {
                settings.preferredThemeCode = defaultThemeCode
            }
        }
    }

    private static var defaultCurrencyCode: String {
        CurrencyConverter.supportedCurrencyCode(from: Locale.current.currency?.identifier)
    }

    private static var defaultThemeCode: String {
        PreferredTheme.system.rawValue
    }
}
