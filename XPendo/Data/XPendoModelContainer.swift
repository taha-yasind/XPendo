import SwiftData

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

    static func container(for mode: AppDataMode) -> ModelContainer {
        switch mode {
        case .standard:
            return standard
        case .demo:
            return demo
        }
    }

    private static func makePersistentContainer(for mode: AppDataMode) -> ModelContainer {
        do {
            return try makeContainer(for: mode, isStoredInMemoryOnly: false)
        } catch {
            print("XPendo \(mode.configurationName) container could not be created: \(error)")
            print("XPendo is falling back to an in-memory store so the app can still launch.")

            do {
                return try makeContainer(for: mode, isStoredInMemoryOnly: true)
            } catch {
                fatalError("Failed to set up \(mode.configurationName) container: \(error)")
            }
        }
    }

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

    private static func cloudKitDatabase(
        for mode: AppDataMode,
        isStoredInMemoryOnly: Bool
    ) -> ModelConfiguration.CloudKitDatabase {
        guard !isStoredInMemoryOnly, mode == .standard else {
            return .none
        }

        return .none
    }
}
