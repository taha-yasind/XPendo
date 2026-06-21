import XCTest
@testable import XPendo

final class ReceiptParserServiceTests: XCTestCase {
    func testParseSimpleMarketReceiptSuggestsAmountDateAndCategory() throws {
        let recognizedText = """
        ACME MARKET
        Tarih 12.05.2026
        GENEL TOPLAM 245,90
        """

        let result = ReceiptParserService.parse(recognizedText)

        XCTAssertEqual(result.title, "ACME MARKET")
        XCTAssertEqual(result.amount ?? 0, 245.90, accuracy: 0.0001)
        XCTAssertEqual(result.categoryName, "Food")
        XCTAssertEqual(result.recognizedText, recognizedText)

        let date = try XCTUnwrap(result.date)
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 5)
        XCTAssertEqual(components.day, 12)
    }

    func testParseTransportReceiptSuggestsTransportCategory() {
        let recognizedText = """
        METRO CARD
        TOTAL 35.50
        """

        let result = ReceiptParserService.parse(recognizedText)

        XCTAssertEqual(result.amount ?? 0, 35.50, accuracy: 0.0001)
        XCTAssertEqual(result.categoryName, "Transport")
    }

    func testEmptyRecognizedTextDoesNotCrashAndReturnsNoAmount() {
        let result = ReceiptParserService.parse("")

        XCTAssertNil(result.title)
        XCTAssertNil(result.amount)
        XCTAssertNil(result.date)
        XCTAssertEqual(result.categoryName, "Other")
        XCTAssertNil(result.note)
    }

    func testParserReturnsSuggestionDataOnly() {
        let result = ReceiptParserService.parse("COFFEE SHOP\nTOTAL 88.25")

        XCTAssertEqual(result.amount ?? 0, 88.25, accuracy: 0.0001)
        XCTAssertEqual(result.categoryName, "Food")
        XCTAssertFalse(result.recognizedText.isEmpty)
    }
}
