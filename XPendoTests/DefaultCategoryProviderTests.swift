import XCTest
@testable import XPendo

final class DefaultCategoryProviderTests: XCTestCase {
    func testDefaultCategoriesAreProvided() {
        XCTAssertFalse(DefaultCategoryProvider.categories.isEmpty)
        XCTAssertEqual(DefaultCategoryProvider.categories.count, 8)
    }

    func testImportantDefaultCategoriesExist() {
        let categoryNames = Set(DefaultCategoryProvider.categories.map(\.name))

        XCTAssertTrue(categoryNames.contains("Food"))
        XCTAssertTrue(categoryNames.contains("Transport"))
        XCTAssertTrue(categoryNames.contains("Shopping"))
        XCTAssertTrue(categoryNames.contains("Bills"))
        XCTAssertTrue(categoryNames.contains("Entertainment"))
        XCTAssertTrue(categoryNames.contains("Health"))
        XCTAssertTrue(categoryNames.contains("Education"))
        XCTAssertTrue(categoryNames.contains("Other"))
    }

    func testDefaultCategoryNamesAreUnique() {
        let names = DefaultCategoryProvider.categories.map(\.name)
        XCTAssertEqual(Set(names).count, names.count)
    }

    func testOtherCategoryExistsWithFallbackStyle() {
        let otherCategory = DefaultCategoryProvider.categories.first { $0.name == "Other" }

        XCTAssertNotNil(otherCategory)
        XCTAssertEqual(otherCategory?.icon, "square.grid.2x2.fill")
        XCTAssertEqual(otherCategory?.color, "#8E8E93")
    }
}
