/*
 DOSYA: AppDataSeeder.swift
 AMAÇ: Yeni kurulum için category ve app settings gibi gerekli default datayı oluşturur. Startup data setup işlemini tek ve öngörülebilir yerde tutar.
 KULLANAN: App launch sırasında AppRootView ve SwiftData model context tarafından kullanılır.
*/
import Foundation
import SwiftData

// AppDataSeeder, uygulama ilk açıldığında gereken başlangıç verilerini oluşturur.
// Default category ve AppSettings kayıtları eksikse SwiftData ModelContext içine eklenir.
enum AppDataSeeder {
    // Seed işlemi ModelContainer kurulurken çağrılır; veri varsa tekrar aynı kayıtları üretmez.
    static func seedIfNeeded(in modelContext: ModelContext) throws {
        try seedDefaultCategories(in: modelContext)
        try seedAppSettings(in: modelContext)

        if modelContext.hasChanges {
            try modelContext.save()
        }
    }

    // Sunumda: category listesi uygulamanın temel sınıflandırma sistemidir.
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

    // Settings kaydı tekil tutulur; theme ve language için varsayılan değerler burada tamamlanır.
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

    // Eski veya tekrar oluşmuş default category kayıtları varsa ilişkiler korunarak tek kayda indirilir.
    private static func deduplicateDefaultCategories(in modelContext: ModelContext) throws {
        let categories = try modelContext.fetch(FetchDescriptor<Category>())
        let expenses = try modelContext.fetch(FetchDescriptor<Expense>())
        let budgets = try modelContext.fetch(FetchDescriptor<Budget>())

        for categoryDefinition in DefaultCategoryProvider.categories {
            let matchingCategories = categories.filter { $0.name == categoryDefinition.name }

            // Gerekli data eksikse erken çıkış yapar.
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

    // Bu type için odaklı bir davranış parçasını yönetir.
    private static var defaultCurrencyCode: String {
        CurrencyConverter.supportedCurrencyCode(from: Locale.current.currency?.identifier)
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private static var defaultThemeCode: String {
        PreferredTheme.system.rawValue
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private static var defaultLanguageCode: String {
        AppLanguage.resolved(from: nil).rawValue
    }
}
