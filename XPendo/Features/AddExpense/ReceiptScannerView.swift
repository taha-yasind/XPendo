import AVFoundation
import PhotosUI
import SwiftUI
import UIKit

// ReceiptScannerView, kamera veya fotoğraf seçimiyle fiş OCR akışını başlatır.
// OCR ve parser sonucu AddExpenseView'a ReceiptScanResult olarak geri döner.
struct ReceiptScannerView: View {
    let onApply: (ReceiptScanResult) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isShowingCamera = false
    @State private var isProcessing = false
    @State private var statusMessage: String?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                SurfaceCard {
                    VStack(alignment: .leading, spacing: 16) {
                        SettingsLikeHeader(
                            title: AppLocalization.string("receiptScan.title"),
                            description: AppLocalization.string("receiptScan.description")
                        )

                        Button(action: openCamera) {
                            scannerActionRow(
                                title: AppLocalization.string("receiptScan.camera.title"),
                                subtitle: cameraSubtitle,
                                icon: "camera.fill"
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(isProcessing)

                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            scannerActionRow(
                                title: AppLocalization.string("receiptScan.photo.title"),
                                subtitle: AppLocalization.string("receiptScan.photo.subtitle"),
                                icon: "photo.fill"
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(isProcessing)
                    }
                }

                if isProcessing {
                    ReceiptScanBanner(
                        text: AppLocalization.string("receiptScan.processing"),
                        icon: "text.viewfinder",
                        tintColor: XPendoTheme.accentTeal
                    )
                }

                if let statusMessage {
                    ReceiptScanBanner(
                        text: statusMessage,
                        icon: "checkmark.circle.fill",
                        tintColor: XPendoTheme.freshGreen
                    )
                }

                if let errorMessage {
                    ReceiptScanBanner(
                        text: errorMessage,
                        icon: "exclamationmark.triangle.fill",
                        tintColor: XPendoTheme.coral
                    )
                }

                Spacer()
            }
            .padding(20)
            .background(XPendoTheme.background.ignoresSafeArea())
            .navigationTitle(AppLocalization.string("receiptScan.navigationTitle"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(AppLocalization.string("common.cancel")) {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingCamera) {
            ReceiptCameraPicker { image in
                Task {
                    // Kamera çıktısı OCR pipeline'a gönderilir; UI thread'i bloklanmaz.
                    await process(image)
                }
            }
            .ignoresSafeArea()
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else {
                return
            }

            Task {
                await loadPhoto(from: newItem)
            }
        }
    }

    private func scannerActionRow(title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(XPendoTheme.accentTeal.opacity(0.12))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: icon)
                        .foregroundStyle(XPendoTheme.accentTeal)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(XPendoTheme.primaryText)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(XPendoTheme.secondaryText)
                    .multilineTextAlignment(.leading)
            }

            Spacer()
        }
        .padding(14)
        .background(XPendoTheme.inputBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .opacity(isProcessing ? 0.6 : 1)
    }

    // Kamera açmadan önce cihaz uygunluğu ve video permission durumu kontrol edilir.
    private func openCamera() {
        guard isCameraAvailable else {
            errorMessage = AppLocalization.string("receiptScan.error.cameraUnavailable")
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isShowingCamera = true
        case .notDetermined:
            Task {
                let granted = await AVCaptureDevice.requestAccess(for: .video)
                await MainActor.run {
                    if granted {
                        isShowingCamera = true
                    } else {
                        errorMessage = AppLocalization.string("receiptScan.error.cameraDenied")
                    }
                }
            }
        case .denied, .restricted:
            errorMessage = AppLocalization.string("receiptScan.error.cameraDenied")
        @unknown default:
            errorMessage = AppLocalization.string("receiptScan.error.cameraUnavailable")
        }
    }

    private var isCameraAvailable: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return UIImagePickerController.isSourceTypeAvailable(.camera)
        #endif
    }

    private var cameraSubtitle: String {
        isCameraAvailable
            ? AppLocalization.string("receiptScan.camera.subtitle")
            : AppLocalization.string("receiptScan.camera.unavailableSubtitle")
    }

    // PhotosPicker'dan gelen görsel Data olarak okunur ve UIImage'a çevrilir.
    private func loadPhoto(from item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                errorMessage = AppLocalization.string("receiptScan.error.imageUnavailable")
                return
            }

            await process(image)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // OCR flow: image -> recognized text -> parser result -> AddExpense form önerileri.
    @MainActor
    private func process(_ image: UIImage) async {
        isProcessing = true
        errorMessage = nil
        statusMessage = nil

        do {
            let recognizedText = try await ReceiptOCRService.recognizeText(in: image)
            let result = ReceiptParserService.parse(recognizedText)
            onApply(result)
            statusMessage = AppLocalization.string("receiptScan.success")
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessing = false
    }
}

// ReceiptCameraPicker, UIKit kamera ekranını SwiftUI içinde kullanmak için UIViewControllerRepresentable adapter'ıdır.
private struct ReceiptCameraPicker: UIViewControllerRepresentable {
    let onImagePicked: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked, dismiss: dismiss)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onImagePicked: (UIImage) -> Void
        let dismiss: DismissAction

        init(onImagePicked: @escaping (UIImage) -> Void, dismiss: DismissAction) {
            self.onImagePicked = onImagePicked
            self.dismiss = dismiss
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                onImagePicked(image)
            }

            dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}

private struct SettingsLikeHeader: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundStyle(XPendoTheme.primaryText)

            Text(description)
                .font(.subheadline)
                .foregroundStyle(XPendoTheme.secondaryText)
        }
    }
}

private struct ReceiptScanBanner: View {
    let text: String
    let icon: String
    let tintColor: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(tintColor)

            Text(text)
                .font(.caption)
                .foregroundStyle(XPendoTheme.secondaryText)

            Spacer()
        }
        .padding(14)
        .background(tintColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
