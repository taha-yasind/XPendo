import XCTest
@testable import XPendo

final class CurrencyConverterTests: XCTestCase {
    func testBaseCurrencyIsTRY() {
        XCTAssertEqual(CurrencyConverter.baseCurrencyCode, "TRY")
    }

    func testSupportedCurrencyCodesResolveExpectedValues() {
        XCTAssertEqual(CurrencyConverter.supportedCurrencyCode(from: "TRY"), "TRY")
        XCTAssertEqual(CurrencyConverter.supportedCurrencyCode(from: "USD"), "USD")
        XCTAssertEqual(CurrencyConverter.supportedCurrencyCode(from: "EUR"), "EUR")
    }

    func testUnsupportedCurrencyFallsBackToTRY() {
        XCTAssertEqual(CurrencyConverter.supportedCurrencyCode(from: "GBP"), "TRY")
        XCTAssertEqual(CurrencyConverter.supportedCurrencyCode(from: nil), "TRY")
    }

    func testFixedLocalRatesAreUsed() {
        XCTAssertEqual(AppCurrency.turkishLira.tryRate, 1.00, accuracy: 0.0001)
        XCTAssertEqual(AppCurrency.usDollar.tryRate, 45.02, accuracy: 0.0001)
        XCTAssertEqual(AppCurrency.euro.tryRate, 52.76, accuracy: 0.0001)
    }

    func testConvertFromTRYToSupportedCurrencies() {
        XCTAssertEqual(CurrencyConverter.convertFromTRY(100, to: "TRY"), 100, accuracy: 0.0001)
        XCTAssertEqual(CurrencyConverter.convertFromTRY(45.02, to: "USD"), 1, accuracy: 0.0001)
        XCTAssertEqual(CurrencyConverter.convertFromTRY(52.76, to: "EUR"), 1, accuracy: 0.0001)
    }

    func testConvertToTRYFromSupportedCurrencies() {
        XCTAssertEqual(CurrencyConverter.convertToTRY(100, from: "TRY"), 100, accuracy: 0.0001)
        XCTAssertEqual(CurrencyConverter.convertToTRY(2, from: "USD"), 90.04, accuracy: 0.0001)
        XCTAssertEqual(CurrencyConverter.convertToTRY(2, from: "EUR"), 105.52, accuracy: 0.0001)
    }

    func testDisplayAmountUsesSameConversionAsConvertFromTRY() {
        let displayedAmount = CurrencyConverter.displayAmount(fromTRY: 45.02, in: "USD")
        XCTAssertEqual(displayedAmount, CurrencyConverter.convertFromTRY(45.02, to: "USD"), accuracy: 0.0001)
    }
}
