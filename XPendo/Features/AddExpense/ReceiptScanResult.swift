import Foundation

// ReceiptScanResult, OCR + parser pipeline'ının AddExpense formuna döndürdüğü öneri modelidir.
// Optional alanlar parser'ın emin olamadığı durumlarda formun mevcut değerlerini korumasını sağlar.
struct ReceiptScanResult {
    let title: String?
    let amount: Double?
    let date: Date?
    let categoryName: String?
    let note: String?
    let recognizedText: String
}
