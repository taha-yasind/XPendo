/*
 DOSYA: ReceiptParserService.swift
 AMAÇ: Recognized receipt text içinden merchant, amount, date ve category ipuçlarını çıkarır. Raw OCR text’i structured scan result verisine dönüştürür.
 KULLANAN: ReceiptOCRService, ReceiptScannerView, AddExpenseViewModel ve parser testleri tarafından kullanılır.
*/
import Foundation

// ReceiptParserService, OCR'dan gelen raw metni kullanıcıya öneri olacak alanlara ayırır.
// Parser sonucu doğrudan kaydetmez; AddExpenseViewModel bu sonucu forma uygular.
enum ReceiptParserService {
    private static let totalKeywords = [
        "GENEL TOPLAM",
        "TOPLAM",
        "TOTAL",
        "TUTAR",
        "AMOUNT"
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

        let title = detectMerchantTitle(in: lines)
        let amount = detectTotalAmount(in: lines)
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

    // Toplam tutar önce total keywords çevresinde aranır; bulunamazsa en büyük pozitif tutar fallback olur.
    private static func detectTotalAmount(in lines: [String]) -> Double? {
        for (index, line) in lines.enumerated() {
            let uppercasedLine = line.uppercased()
            // Gerekli data eksikse erken çıkış yapar.
            guard totalKeywords.contains(where: { uppercasedLine.contains($0) }) else {
                continue
            }

            if let amount = extractAmounts(from: line).last {
                return amount
            }

            if index + 1 < lines.count, let amount = extractAmounts(from: lines[index + 1]).last {
                return amount
            }
        }

        return lines
            .flatMap(extractAmounts)
            .filter { $0 > 0 }
            .max()
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
