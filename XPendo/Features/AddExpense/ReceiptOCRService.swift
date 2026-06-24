/*
 DOSYA: ReceiptOCRService.swift
 AMAÇ: Receipt görsellerinde Apple Vision text recognition çalıştırır. OCR detaylarını add-expense ekranından izole eder.
 KULLANAN: Receipt scanning akışlarında ReceiptScannerView ve AddExpenseViewModel tarafından kullanılır.
*/
import UIKit
import Vision

// ReceiptOCRError, OCR sırasında kullanıcıya gösterilecek localized hata tiplerini tanımlar.
enum ReceiptOCRError: LocalizedError {
    case imageUnavailable
    case noTextDetected

    // Bu type için odaklı bir davranış parçasını yönetir.
    var errorDescription: String? {
        switch self {
        case .imageUnavailable:
            return AppLocalization.string("receiptScan.error.imageUnavailable")
        case .noTextDetected:
            return AppLocalization.string("receiptScan.error.noTextDetected")
        }
    }
}

// ReceiptOCRService, Vision framework ile fiş görselinden metin çıkarır.
// Bu service yalnızca raw recognized text üretir; amount/date/category yorumlamasını parser yapar.
enum ReceiptOCRService {
    // OCR işi background Task üzerinde çalışır ve boş sonuçta noTextDetected hatası döndürür.
    static func recognizeText(in image: UIImage) async throws -> String {
        // Gerekli data eksikse erken çıkış yapar.
        guard let cgImage = image.cgImage else {
            throw ReceiptOCRError.imageUnavailable
        }

        let lines = try await Task.detached(priority: .userInitiated) {
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            // Fiş metni doğal dil değildir; language correction semboller ve sayıları yanlış "düzeltebilir.
            request.usesLanguageCorrection = false
            request.recognitionLanguages = ["tr-TR", "en-US"]

            let handler = VNImageRequestHandler(cgImage: cgImage)
            try handler.perform([request])

            let observations = request.results ?? []
            return observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
        }.value

        let recognizedText = lines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")

        // Gerekli data eksikse erken çıkış yapar.
        guard !recognizedText.isEmpty else {
            throw ReceiptOCRError.noTextDetected
        }

        return recognizedText
    }
}
