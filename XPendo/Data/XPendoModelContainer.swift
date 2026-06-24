/*
 DOSYA: XPendoModelContainer.swift
 AMAÇ: App’in kullandığı SwiftData model container ve schema yapılandırmasını yapar. Launch kodu küçük kalsın diye persistence setup işlemini merkezileştirir.
 KULLANAN: XPendoApp, previewler ve shared SwiftData store’a ihtiyaç duyan kodlar tarafından kullanılır.
*/
import SwiftData

// XPendoModelContainer, SwiftData schema ve ModelContainer kurulumundan sorumludur.
// App launch sırasında standard veya demo data store seçimini XPendoApp buradan alır.
enum XPendoModelContainer {
    static let standard: ModelContainer = makePersistentContainer(for: .standard)
    static let demo: ModelContainer = makePersistentContainer(for: .demo)
    static let shared: ModelContainer = standard

    private static let schema = Schema([
        Expense.self,
        Category.self,
        Budget.self,
        AppSettings.self
    ])

    // Bu type için odaklı bir davranış parçasını yönetir.
    static func container(for mode: AppDataMode) -> ModelContainer {
        switch mode {
        case .standard:
            return standard
        case .demo:
            return demo
        }
    }

    // Persistent store açılamazsa uygulamanın launch edebilmesi için in-memory fallback denenir.
    private static func makePersistentContainer(for mode: AppDataMode) -> ModelContainer {
        // Error fırlatabilecek işi başlatır.
        do {
            return try makeContainer(for: mode, isStoredInMemoryOnly: false)
        } catch {
            print("XPendo \(mode.configurationName) container could not be created: \(error)")
            print("XPendo is falling back to an in-memory store so the app can still launch.")

            // Error fırlatabilecek işi başlatır.
            do {
                return try makeContainer(for: mode, isStoredInMemoryOnly: true)
            } catch {
                fatalError("Failed to set up \(mode.configurationName) container: \(error)")
            }
        }
    }

    // ModelContainer oluşturulduktan sonra temel category ve settings kayıtları seed edilir.
    private static func makeContainer(for mode: AppDataMode, isStoredInMemoryOnly: Bool) throws -> ModelContainer {
        let configuration = ModelConfiguration(
            mode.configurationName,
            schema: schema,
            isStoredInMemoryOnly: isStoredInMemoryOnly,
            cloudKitDatabase: cloudKitDatabase(for: mode, isStoredInMemoryOnly: isStoredInMemoryOnly)
        )

        let container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )

        try AppDataSeeder.seedIfNeeded(in: container.mainContext)
        return container
    }

    // CloudKit entegrasyonu için karar noktası burada tutulur; şu an local SwiftData store kullanılır.
    private static func cloudKitDatabase(
        for mode: AppDataMode,
        isStoredInMemoryOnly: Bool
    ) -> ModelConfiguration.CloudKitDatabase {
        // Gerekli data eksikse erken çıkış yapar.
        guard !isStoredInMemoryOnly, mode == .standard else {
            return .none
        }

        return .none
    }
}
