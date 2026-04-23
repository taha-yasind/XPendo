import SwiftData

enum XPendoModelContainer {
    static let shared: ModelContainer = {
        do {
            return try makeContainer(isStoredInMemoryOnly: false)
        } catch {
            print("XPendo persistent container could not be created: \(error)")
            print("XPendo is falling back to an in-memory store so the app can still launch.")

            do {
                return try makeContainer(isStoredInMemoryOnly: true)
            } catch {
                fatalError("Failed to set up any SwiftData container: \(error)")
            }
        }
    }()

    private static let schema = Schema([
        Expense.self,
        Category.self,
        Budget.self,
        AppSettings.self
    ])

    private static func makeContainer(isStoredInMemoryOnly: Bool) throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: isStoredInMemoryOnly
        )

        let container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )

        try AppDataSeeder.seedIfNeeded(in: container.mainContext)
        return container
    }
}
