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
                id: categoryDefinition.id,
                name: categoryDefinition.name,
                icon: categoryDefinition.icon,
                color: categoryDefinition.color,
                isDefault: true
            )

            modelContext.insert(category)
        }

        try deduplicateDefaultCategories(in: modelContext)
    }

    private static func seedAppSettings(in modelContext: ModelContext) throws {
        let existingSettings = try modelContext.fetch(FetchDescriptor<AppSettings>())

        if existingSettings.isEmpty {
            let settings = AppSettings(
                currencyCode: defaultCurrencyCode,
                preferredThemeCode: defaultThemeCode,
                preferredLanguageCode: defaultLanguageCode
            )
            modelContext.insert(settings)
            return
        }

        for settings in existingSettings {
            if settings.preferredThemeCode?.isEmpty != false {
                settings.preferredThemeCode = defaultThemeCode
            }
            if settings.preferredLanguageCode?.isEmpty != false {
                settings.preferredLanguageCode = defaultLanguageCode
            }
        }

        for duplicateSettings in existingSettings.dropFirst() {
            modelContext.delete(duplicateSettings)
        }
    }

    private static func deduplicateDefaultCategories(in modelContext: ModelContext) throws {
        let categories = try modelContext.fetch(FetchDescriptor<Category>())
        let expenses = try modelContext.fetch(FetchDescriptor<Expense>())
        let budgets = try modelContext.fetch(FetchDescriptor<Budget>())

        for categoryDefinition in DefaultCategoryProvider.categories {
            let matchingCategories = categories.filter { $0.name == categoryDefinition.name }

            guard matchingCategories.count > 1 else {
                continue
            }

            let preferredCategory = matchingCategories.first(where: { $0.id == categoryDefinition.id }) ?? matchingCategories[0]
            preferredCategory.id = categoryDefinition.id
            preferredCategory.icon = categoryDefinition.icon
            preferredCategory.color = categoryDefinition.color
            preferredCategory.isDefault = true

            for duplicateCategory in matchingCategories where duplicateCategory !== preferredCategory {
                for expense in expenses where expense.category?.id == duplicateCategory.id {
                    expense.category = preferredCategory
                }

                for budget in budgets where budget.category?.id == duplicateCategory.id {
                    budget.category = preferredCategory
                }

                modelContext.delete(duplicateCategory)
            }
        }
    }

    private static var defaultCurrencyCode: String {
        CurrencyConverter.supportedCurrencyCode(from: Locale.current.currency?.identifier)
    }

    private static var defaultThemeCode: String {
        PreferredTheme.system.rawValue
    }

    private static var defaultLanguageCode: String {
        AppLanguage.resolved(from: nil).rawValue
    }
}
