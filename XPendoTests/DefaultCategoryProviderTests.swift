import XCTest
@testable import XPendo

// AMAÇ: Uygulama ilk açıldığında oluşturulan varsayılan kategorilerin doğru tanımlandığını doğrular.
// DefaultCategoryProvider, kullanıcıya herhangi bir kurulum yapmadan harcama girebileceği 8 kategori sunar.
final class DefaultCategoryProviderTests: XCTestCase {

    // Varsayılan kategori listesinin boş olmadığını ve tam olarak 8 kategori içerdiğini doğrular.
    // Kategori sayısı değişirse harcama girişinde beklenmedik davranışlar oluşabilir.
    func testDefaultCategoriesAreProvided() {
        XCTAssertFalse(DefaultCategoryProvider.categories.isEmpty)
        XCTAssertEqual(DefaultCategoryProvider.categories.count, 8)
    }

    // 8 varsayılan kategorinin tamamının listede bulunduğunu isim bazında doğrular.
    // Herhangi bir kategorinin eksik olması kullanıcının o harcama türünü sınıflandıramamasına yol açar.
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

    // Kategori isimlerinin birbirinden farklı (unique) olduğunu doğrular.
    // Aynı isimde iki kategori olursa kullanıcı hangisini seçtiğini ayırt edemez.
    func testDefaultCategoryNamesAreUnique() {
        let names = DefaultCategoryProvider.categories.map(\.name)
        XCTAssertEqual(Set(names).count, names.count)
    }

    // "Other" kategorisinin var olduğunu ve fallback ikon/renk değerleriyle tanımlandığını doğrular.
    // OCR tanıma başarısız olduğunda veya kategori eşleşmediğinde "Other" güvenli varsayılan olarak kullanılır.
    func testOtherCategoryExistsWithFallbackStyle() {
        let otherCategory = DefaultCategoryProvider.categories.first { $0.name == "Other" }

        XCTAssertNotNil(otherCategory)
        XCTAssertEqual(otherCategory?.icon, "square.grid.2x2.fill")
        XCTAssertEqual(otherCategory?.color, "#8E8E93")
    }
}
