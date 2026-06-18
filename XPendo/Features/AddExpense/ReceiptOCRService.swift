import UIKit
import Vision

enum ReceiptOCRError: LocalizedError {
    case imageUnavailable
    case noTextDetected

    var errorDescription: String? {
        switch self {
        case .imageUnavailable:
            return AppLocalization.string("receiptScan.error.imageUnavailable")
        case .noTextDetected:
            return AppLocalization.string("receiptScan.error.noTextDetected")
        }
    }
}

enum ReceiptOCRService {
    static func recognizeText(in image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw ReceiptOCRError.imageUnavailable
        }

        let lines = try await Task.detached(priority: .userInitiated) {
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
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

        guard !recognizedText.isEmpty else {
            throw ReceiptOCRError.noTextDetected
        }

        return recognizedText
    }
}
