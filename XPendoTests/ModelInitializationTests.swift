import XCTest
@testable import XPendo

// AMAÇ: SwiftData model nesnelerinin (Category, Expense, Budget, AppSettings) başlatılınca
// verilen değerleri doğru şekilde sakladığını doğrular.
// Bu testler veri katmanının temelini oluşturur — model davranışı bozulursa tüm uygulama etkilenir.
final class ModelInitializationTests: XCTestCase {

    // Category nesnesinin id, name, icon, color ve isDefault değerlerini doğru sakladığını doğrular.
    func testCategoryInitializationStoresProvidedValues() {
        let id = UUID()
        let category = Category(
            id: id,
            name: "Food",
            icon: "fork.knife",
            color: "#00BFA5",
            isDefault: true
        )

        XCTAssertEqual(category.id, id)
        XCTAssertEqual(category.name, "Food")
        XCTAssertEqual(category.icon, "fork.knife")
        XCTAssertEqual(category.color, "#00BFA5")
        XCTAssertTrue(category.isDefault)
    }

    // Expense nesnesinin title, amount, date, category ve note değerlerini doğru sakladığını doğrular.
    // amount TRY cinsinden saklanır; categoryName, categoryIcon ve categoryColor ilişkili Category'den gelir.
    func testExpenseInitializationStoresProvidedValues() {
        let category = Category(name: "Food", icon: "fork.knife", color: "#00BFA5")
        let date = Date(timeIntervalSince1970: 1_800_000_000)
        let expense = Expense(
            title: "Lunch",
            amount: 250,
            date: date,
            category: category,
            note: "Cafe"
        )

        XCTAssertEqual(expense.title, "Lunch")
        XCTAssertEqual(expense.amount, 250, accuracy: 0.0001)
        XCTAssertEqual(expense.date, date)
        XCTAssertEqual(expense.note, "Cafe")
        XCTAssertEqual(expense.categoryName, "Food")
        XCTAssertEqual(expense.categoryIcon, "fork.knife")
        XCTAssertEqual(expense.categoryColor, "#00BFA5")
    }

    // Budget nesnesinin limitAmount, month, year ve ilişkili kategori bilgilerini doğru sakladığını doğrular.
    // Budget her zaman bir kategoriye bağlıdır; aylık limit bu ilişki üzerinden takip edilir.
    func testBudgetInitializationStoresProvidedValues() {
        let category = Category(name: "Transport", icon: "car.fill", color: "#27AE60")
        let budget = Budget(
            category: category,
            limitAmount: 3_000,
            month: 6,
            year: 2026
        )

        XCTAssertEqual(budget.limitAmount, 3_000, accuracy: 0.0001)
        XCTAssertEqual(budget.month, 6)
        XCTAssertEqual(budget.year, 2026)
        XCTAssertEqual(budget.categoryName, "Transport")
        XCTAssertEqual(budget.categoryIcon, "car.fill")
        XCTAssertEqual(budget.categoryColor, "#27AE60")
    }

    // AppSettings nesnesinin kullanıcı tercihlerini (para birimi, tema, dil, bildirim ayarları) doğru sakladığını doğrular.
    // Bu model Settings ekranında değiştirilen tüm tercihlerin kalıcı kaynağıdır.
    func testAppSettingsInitializationStoresProvidedValues() {
        let settings = AppSettings(
            currencyCode: "USD",
            preferredThemeCode: PreferredTheme.dark.rawValue,
            preferredLanguageCode: "en",
            notificationsEnabled: true,
            dailyReminderEnabled: true,
            budgetWarningEnabled: false
        )

        XCTAssertEqual(settings.currencyCode, "USD")
        XCTAssertEqual(settings.preferredThemeCode, PreferredTheme.dark.rawValue)
        XCTAssertEqual(settings.preferredLanguageCode, "en")
        XCTAssertTrue(settings.notificationsEnabled)
        XCTAssertTrue(settings.dailyReminderEnabled)
        XCTAssertFalse(settings.budgetWarningEnabled)
    }
}
