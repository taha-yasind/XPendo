import XCTest
@testable import XPendo

// AMAÇ: CurrencyConverter'ın döviz kuru sabitlerini ve çevrim fonksiyonlarını doğrular.
// Tüm tutarlar veritabanında TRY olarak saklanır; bu testler dönüşüm mantığının doğru çalıştığını garantiler.
final class CurrencyConverterTests: XCTestCase {

    // Uygulamanın taban para biriminin TRY olduğunu doğrular.
    // TRY dışında bir değer dönerse tüm çevrim hesaplamaları hatalı sonuç üretir.
    func testBaseCurrencyIsTRY() {
        XCTAssertEqual(CurrencyConverter.baseCurrencyCode, "TRY")
    }

    // Desteklenen para birimi kodlarının (TRY, USD, EUR) olduğu gibi döndüğünü doğrular.
    func testSupportedCurrencyCodesResolveExpectedValues() {
        XCTAssertEqual(CurrencyConverter.supportedCurrencyCode(from: "TRY"), "TRY")
        XCTAssertEqual(CurrencyConverter.supportedCurrencyCode(from: "USD"), "USD")
        XCTAssertEqual(CurrencyConverter.supportedCurrencyCode(from: "EUR"), "EUR")
    }

    // Desteklenmeyen (GBP) veya nil para birimi girildiğinde TRY'ye düştüğünü doğrular.
    // Bilinmeyen para birimiyle uygulama crash vermemeli, güvenli varsayılana dönmeli.
    func testUnsupportedCurrencyFallsBackToTRY() {
        XCTAssertEqual(CurrencyConverter.supportedCurrencyCode(from: "GBP"), "TRY")
        XCTAssertEqual(CurrencyConverter.supportedCurrencyCode(from: nil), "TRY")
    }

    // CurrencyConverter.swift'teki hardcode döviz kurlarının beklenen değerlerde olduğunu doğrular.
    // USD=45.02 ve EUR=52.76 — bu değerler değişirse tüm geçmiş dönüşümler etkilenir.
    func testFixedLocalRatesAreUsed() {
        XCTAssertEqual(AppCurrency.turkishLira.tryRate, 1.00, accuracy: 0.0001)
        XCTAssertEqual(AppCurrency.usDollar.tryRate, 45.02, accuracy: 0.0001)
        XCTAssertEqual(AppCurrency.euro.tryRate, 52.76, accuracy: 0.0001)
    }

    // TRY cinsinden saklanan tutarın ekranda gösterim için doğru para birimine çevrildiğini doğrular.
    // Örnek: 45.02 TRY → 1 USD, 52.76 TRY → 1 EUR.
    func testConvertFromTRYToSupportedCurrencies() {
        XCTAssertEqual(CurrencyConverter.convertFromTRY(100, to: "TRY"), 100, accuracy: 0.0001)
        XCTAssertEqual(CurrencyConverter.convertFromTRY(45.02, to: "USD"), 1, accuracy: 0.0001)
        XCTAssertEqual(CurrencyConverter.convertFromTRY(52.76, to: "EUR"), 1, accuracy: 0.0001)
    }

    // Kullanıcının girdiği tutarın veritabanına kaydedilmeden önce TRY'ye doğru çevrildiğini doğrular.
    // Örnek: 2 USD → 90.04 TRY, 2 EUR → 105.52 TRY.
    func testConvertToTRYFromSupportedCurrencies() {
        XCTAssertEqual(CurrencyConverter.convertToTRY(100, from: "TRY"), 100, accuracy: 0.0001)
        XCTAssertEqual(CurrencyConverter.convertToTRY(2, from: "USD"), 90.04, accuracy: 0.0001)
        XCTAssertEqual(CurrencyConverter.convertToTRY(2, from: "EUR"), 105.52, accuracy: 0.0001)
    }

    // displayAmount fonksiyonunun convertFromTRY ile tutarlı sonuç ürettiğini doğrular.
    // İki farklı çağrı yolu aynı sonucu vermeli — ekranda yanlış tutar gösterilmemeli.
    func testDisplayAmountUsesSameConversionAsConvertFromTRY() {
        let displayedAmount = CurrencyConverter.displayAmount(fromTRY: 45.02, in: "USD")
        XCTAssertEqual(displayedAmount, CurrencyConverter.convertFromTRY(45.02, to: "USD"), accuracy: 0.0001)
    }
}
