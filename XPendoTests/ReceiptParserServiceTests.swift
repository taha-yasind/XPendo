import XCTest
@testable import XPendo

// AMAÇ: Vision Framework'ün OCR ile tanıdığı ham metinden ReceiptParserService'in
// tutar, tarih, başlık ve kategori önerilerini doğru çıkarıp çıkarmadığını doğrular.
// OCR sonuçları hiçbir zaman otomatik kaydedilmez — bu testler yalnızca öneri mantığını kapsar.
final class ReceiptParserServiceTests: XCTestCase {

    // Basit bir market fişi metninden başlık, tutar, tarih ve kategori önerisinin doğru çıkarıldığını doğrular.
    // "GENEL TOPLAM" ifadesi tutarı, "Tarih" ifadesi tarihi, "MARKET" kelimesi Food kategorisini tetikler.
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

    // "METRO CARD" gibi ulaşım anahtar kelimeleri içeren fişin Transport kategorisine eşlendiğini doğrular.
    // Parser, metin içindeki anahtar kelimelere göre kategori tahmini yapar.
    func testParseTransportReceiptSuggestsTransportCategory() {
        let recognizedText = """
        METRO CARD
        TOTAL 35.50
        """

        let result = ReceiptParserService.parse(recognizedText)

        XCTAssertEqual(result.amount ?? 0, 35.50, accuracy: 0.0001)
        XCTAssertEqual(result.categoryName, "Transport")
    }

    // Boş metin girildiğinde uygulamanın crash vermediğini ve tüm alanların nil döndüğünü doğrular.
    // OCR kötü ışıkta hiçbir metin tanıyamazsa güvenli bir sonuç dönmeli, kategori "Other" olmalı.
    func testEmptyRecognizedTextDoesNotCrashAndReturnsNoAmount() {
        let result = ReceiptParserService.parse("")

        XCTAssertNil(result.title)
        XCTAssertNil(result.amount)
        XCTAssertNil(result.date)
        XCTAssertEqual(result.categoryName, "Other")
        XCTAssertNil(result.note)
    }

    // Parser sonucunun yalnızca öneri verisi içerdiğini doğrular — kayıt işlemi tetiklenmez.
    // OCR sonucu forma önerilir; kullanıcı Save'e basmadan hiçbir şey SwiftData'ya yazılmaz.
    func testParserReturnsSuggestionDataOnly() {
        let result = ReceiptParserService.parse("COFFEE SHOP\nTOTAL 88.25")

        XCTAssertEqual(result.amount ?? 0, 88.25, accuracy: 0.0001)
        XCTAssertEqual(result.categoryName, "Food")
        XCTAssertFalse(result.recognizedText.isEmpty)
    }
}
