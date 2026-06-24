/*
 DOSYA: ReceiptParserService.swift
 AMAÇ: Recognized receipt text içinden merchant, amount, date ve category ipuçlarını çıkarır. Raw OCR text’i structured scan result verisine dönüştürür.
 KULLANAN: ReceiptOCRService, ReceiptScannerView, AddExpenseViewModel ve parser testleri tarafından kullanılır.
*/
import Foundation

// ReceiptParserService, OCR'dan gelen raw metni kullanıcıya öneri olacak alanlara ayırır.
// Parser sonucu doğrudan kaydetmez; AddExpenseViewModel bu sonucu forma uygular.
enum ReceiptParserService {
    // Daha spesifik keyword grupları önce denenir; ilk eşleşen grup kazanır.
    private static let prioritizedTotalKeywordGroups: [[String]] = [
        ["GENEL TOPLAM", "GRAND TOTAL"],
        ["TOPLAM", "TOTAL"],
        ["TUTAR", "AMOUNT"]
    ]

    // Bu satırlar hiçbir zaman toplam satırı sayılmaz; KDV, iskonto ve vergi satırları hariçtir.
    private static let excludedLineKeywords = [
        "KDV", "TOPKDV", "TAX", "VAT",
        "ISKONTO", "İNDİRİM", "INDIRIM", "DISCOUNT"
    ]

    private static let ignoredTitleKeywords = [
        "fis",
        "fiş",
        "fatura",
        "receipt",
        "invoice",
        "tarih",
        "date",
        "saat",
        "tel",
        "tax",
        "kdv",
        "total",
        "toplam"
    ]

    // Recognized text satırlara ayrılır ve title, amount, date, category, note tahminleri üretilir.
    static func parse(_ recognizedText: String) -> ReceiptScanResult {
        let lines = recognizedText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // DEBUG — Xcode konsolunda OCR çıktısını görmek için
        print("=== OCR LINES ===")
        lines.enumerated().forEach { print("[\($0.offset)] \($0.element)") }
        print("=================")

        let title = detectMerchantTitle(in: lines)
        let amount = detectTotalAmount(in: lines)
        print("=== DETECTED AMOUNT: \(String(describing: amount)) ===")
        let date = detectDate(in: lines)
        let categoryName = detectCategoryName(in: lines)
        let note = makeNote(from: lines)

        return ReceiptScanResult(
            title: title,
            amount: amount,
            date: date,
            categoryName: categoryName,
            note: note,
            recognizedText: recognizedText
        )
    }

    // Merchant title için fiş başındaki açıklayıcı satırlar aranır, toplam/tarih gibi teknik satırlar atlanır.
    private static func detectMerchantTitle(in lines: [String]) -> String? {
        lines.prefix(8).first { line in
            let normalized = line.lowercased()
            let hasLetter = normalized.rangeOfCharacter(from: .letters) != nil
            let isIgnored = ignoredTitleKeywords.contains { normalized.contains($0) }
            return hasLetter && !isIgnored && line.count >= 3
        }
    }

    // Toplam tutar öncelikli keyword gruplarıyla taranır; daha spesifik grup (GENEL TOPLAM) her zaman önce denenir.
    // Aynı gruptaki tüm adaylar toplanır ve en büyük tutar seçilir; böylece ara toplam yerine genel toplam alınır.
    // KDV, iskonto ve vergi satırları exclude listesiyle atlanır. Hiçbir eşleşme yoksa fallback olarak en büyük tutar kullanılır.
    private static func detectTotalAmount(in lines: [String]) -> Double? {
        let normalized = lines.map(normalizeLine)

        for keywords in prioritizedTotalKeywordGroups {
            var candidates: [Double] = []

            for (index, line) in normalized.enumerated() {
                let uppercased = line.uppercased()
                let isExcluded = excludedLineKeywords.contains { uppercased.contains($0) }
                let matchesKeyword = keywords.contains { uppercased.contains($0) }

                guard matchesKeyword, !isExcluded else { continue }

                // Anahtar kelime ile aynı satırda tutar varsa direkt kullan.
                if let amount = extractAmounts(from: line).last {
                    candidates.append(amount)
                    continue
                }

                // Aynı satırda tutar yoksa ±3 satırlık penceredeki tüm tutarları topla.
                // OCR bazen sütunları karışık sırayla okur; önceki ve sonraki satırları da taramamız gerekir.
                let windowStart = max(0, index - 3)
                let windowEnd = min(normalized.count - 1, index + 3)
                let windowAmounts: [Double] = (windowStart...windowEnd)
                    .filter { $0 != index }
                    .compactMap { i -> Double? in
                        let windowLine = normalized[i]
                        let windowUpper = windowLine.uppercased()
                        guard !excludedLineKeywords.contains(where: { windowUpper.contains($0) }) else { return nil }
                        return extractAmounts(from: windowLine).last
                    }

                // Penceredeki en büyük tutar genel toplamı temsil eder.
                if let best = windowAmounts.max() {
                    candidates.append(best)
                }
            }

            // Aynı öncelik grubundaki en büyük tutar genel toplamı temsil eder.
            if let best = candidates.max() {
                return best
            }
        }

        return normalized
            .flatMap(extractAmounts)
            .filter { $0 > 0 }
            .max()
    }

    // OCR gürültüsünü (asterisk, fazla boşluk) temizler; keyword ve tutar eşleştirme doğruluğunu artırır.
    private static func normalizeLine(_ line: String) -> String {
        line
            .replacingOccurrences(of: "*", with: " ")
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // Raw input’u structured app data’ya dönüştürür.
    private static func extractAmounts(from text: String) -> [Double] {
        let pattern = #"\d{1,3}(?:[.,]\d{3})*[.,]\d{2}|\d+[.,]\d{2}"#
        // Gerekli data eksikse erken çıkış yapar.
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }

        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.matches(in: text, range: range).compactMap { match in
            // Gerekli data eksikse erken çıkış yapar.
            guard let matchRange = Range(match.range, in: text) else {
                return nil
            }

            return parseAmount(String(text[matchRange]))
        }
    }

    // Amount parser, Türkçe ve İngilizce decimal/thousands separator yazımlarını normalize eder.
    private static func parseAmount(_ rawValue: String) -> Double? {
        let digitsAndSeparators = rawValue.filter { $0.isNumber || $0 == "," || $0 == "." }
        // Gerekli data eksikse erken çıkış yapar.
        guard !digitsAndSeparators.isEmpty else {
            return nil
        }

        let lastComma = digitsAndSeparators.lastIndex(of: ",")
        let lastDot = digitsAndSeparators.lastIndex(of: ".")

        if let lastComma, let lastDot {
            let decimalSeparator: Character = lastComma > lastDot ? "," : "."
            let thousandsSeparator: Character = decimalSeparator == "," ? "." : ","
            return Double(
                digitsAndSeparators
                    .replacingOccurrences(of: String(thousandsSeparator), with: "")
                    .replacingOccurrences(of: String(decimalSeparator), with: ".")
            )
        }

        if digitsAndSeparators.contains(",") {
            return Double(digitsAndSeparators.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: "."))
        }

        return Double(digitsAndSeparators.replacingOccurrences(of: ",", with: ""))
    }

    // Fişlerde yaygın tarih formatları denenerek Date önerisi çıkarılır.
    private static func detectDate(in lines: [String]) -> Date? {
        let text = lines.joined(separator: " ")
        let patterns = [
            #"\b\d{2}[.]\d{2}[.]\d{4}\b"#,
            #"\b\d{2}[/]\d{2}[/]\d{4}\b"#,
            #"\b\d{4}-\d{2}-\d{2}\b"#
        ]
        let formats = ["dd.MM.yyyy", "dd/MM/yyyy", "yyyy-MM-dd"]

        for (pattern, format) in zip(patterns, formats) {
            // Gerekli data eksikse erken çıkış yapar.
            guard let match = firstMatch(for: pattern, in: text) else {
                continue
            }

            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US_POSIX")

            if let date = formatter.date(from: match) {
                return date
            }
        }

        return nil
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private static func firstMatch(for pattern: String, in text: String) -> String? {
        // Gerekli data eksikse erken çıkış yapar.
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }

        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard
            let match = regex.firstMatch(in: text, range: range),
            let matchRange = Range(match.range, in: text)
        else {
            return nil
        }

        return String(text[matchRange])
    }

    // Basit keyword eşleştirme ile category önerisi yapılır; emin olunamazsa Other döner.
    private static func detectCategoryName(in lines: [String]) -> String {
        let text = lines.joined(separator: " ").lowercased()

        if containsAny(["market", "grocery", "supermarket", "migros", "carrefour", "restaurant", "cafe", "coffee", "starbucks"], in: text) {
            return "Food"
        }
        if containsAny(["bus", "metro", "taxi", "fuel", "gas", "benzin", "akaryakit", "akaryakıt"], in: text) {
            return "Transport"
        }
        if containsAny(["pharmacy", "hospital", "clinic", "eczane", "hastane"], in: text) {
            return "Health"
        }
        if containsAny(["cinema", "movie", "game", "sinema", "oyun"], in: text) {
            return "Entertainment"
        }
        if containsAny(["school", "book", "course", "okul", "kitap", "kurs"], in: text) {
            return "Education"
        }

        return "Other"
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private static func containsAny(_ keywords: [String], in text: String) -> Bool {
        keywords.contains { text.contains($0) }
    }

    // Note alanı, kullanıcıya OCR kaynağını hatırlatacak kısa bir fiş önizlemesi taşır.
    private static func makeNote(from lines: [String]) -> String? {
        let preview = lines.prefix(4).joined(separator: " | ")
        return preview.isEmpty ? nil : preview
    }
}
