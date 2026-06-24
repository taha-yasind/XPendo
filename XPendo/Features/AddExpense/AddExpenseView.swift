/*
 DOSYA: AddExpenseView.swift
 AMAÇ: Receipt scan sonuçları dahil, expense manuel ekleme veya düzenleme formunu sunar. User input’u AddExpenseViewModel aksiyonlarına bağlar.
 KULLANAN: HomeView, ExpensesView, FloatingAddButton, ReceiptScannerView ve AddExpenseViewModel tarafından kullanılır.
*/
import SwiftUI
import SwiftData

// AddExpenseView, harcama ekleme ve düzenleme formunun SwiftUI ekranıdır.
// ViewModel validation ve persistence işini yaparken bu View form, OCR sheet ve hata durumlarını gösterir.
struct AddExpenseView: View {
    let expenseToEdit: Expense?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Category.name) private var categories: [Category]
    @Query private var settings: [AppSettings]

    @FocusState private var focusedField: Field?
    @State private var viewModel: AddExpenseViewModel
    @State private var saveErrorMessage: String?
    @State private var isShowingReceiptScanner = false

    // expenseToEdit verilirse ekran edit modunda çalışır; nil ise yeni Expense ekleme akışı başlar.
    init(expenseToEdit: Expense? = nil) {
        self.expenseToEdit = expenseToEdit
        _viewModel = State(initialValue: AddExpenseViewModel(expenseToEdit: expenseToEdit))
    }

    // Bu view için görünen SwiftUI layout’unu kurar.
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                entryFormSection

                if let validationMessage = viewModel.validationMessage {
                    ValidationBanner(message: validationMessage)
                }

                if let receiptScanMessage = viewModel.receiptScanMessage {
                    ReceiptSuggestionBanner(message: receiptScanMessage)
                }

                saveSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .background(XPendoTheme.background.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(AppLocalization.string("common.done")) {
                    focusedField = nil
                }
                .fontWeight(.semibold)
                .foregroundStyle(XPendoTheme.accentTeal)
            }
        }
        .task(id: expenseFormSyncKey) {
            // Category veya currency değiştiğinde form state'i ViewModel ile tekrar senkronize edilir.
            viewModel.prepareForm(categories: categories, displayCurrencyCode: currencyCode)
        }
        .alert(AppLocalization.string("addExpense.alert.saveFailed.title"), isPresented: saveErrorBinding) {
            Button(AppLocalization.string("common.ok"), role: .cancel) { }
        } message: {
            Text(saveErrorMessage ?? AppLocalization.string("common.tryAgain"))
        }
        .sheet(isPresented: $isShowingReceiptScanner) {
            ReceiptScannerView { result in
                // OCR sonucu form alanlarına aktarılır; kayıt işlemi yine Save butonu ile yapılır.
                viewModel.applyReceiptScanResult(result, categories: categories)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(XPendoTheme.background)
        }
    }

    // Header, add/edit moduna göre title değiştirir ve yeni kayıt modunda OCR scanner girişini gösterir.
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.screenTitle)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(XPendoTheme.primaryText)

                Text(viewModel.screenSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(XPendoTheme.secondaryText)
            }

            Spacer()

            if expenseToEdit == nil {
                Button {
                    focusedField = nil
                    isShowingReceiptScanner = true
                } label: {
                    Image(systemName: "camera.fill")
                        .font(.headline)
                        .foregroundStyle(XPendoTheme.accentTeal)
                        .frame(width: 44, height: 44)
                        .background(XPendoTheme.surfaceBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(XPendoTheme.cardBorder, lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(AppLocalization.string("receiptScan.accessibility.open"))
            }

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundStyle(XPendoTheme.primaryText)
                    .frame(width: 44, height: 44)
                    .background(XPendoTheme.surfaceBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(XPendoTheme.cardBorder, lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
        }
    }

    // Form alanları ViewModel state'ine binding ile bağlıdır; validation ViewModel tarafında kalır.
    private var entryFormSection: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 18) {
                Text(AppLocalization.string("addExpense.section.details"))
                    .font(.headline)
                    .foregroundStyle(XPendoTheme.primaryText)

                categorySection

                LabeledField(title: AppLocalization.string("addExpense.field.title"), icon: "textformat") {
                    TextField(AppLocalization.string("addExpense.placeholder.title"), text: $viewModel.title)
                        .focused($focusedField, equals: .title)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .amount
                        }
                }

                LabeledField(title: AppLocalization.string("addExpense.field.amount"), icon: "creditcard") {
                    HStack(spacing: 12) {
                        TextField("0.00", text: $viewModel.amountText)
                            .focused($focusedField, equals: .amount)
                            .keyboardType(.decimalPad)

                        Text(currencyCode)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(XPendoTheme.accentTeal)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(XPendoTheme.accentTeal.opacity(0.12), in: Capsule())
                    }
                }

                LabeledField(title: AppLocalization.string("addExpense.field.date"), icon: "calendar") {
                    DatePicker(
                        AppLocalization.string("addExpense.field.expenseDate"),
                        selection: $viewModel.date,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .datePickerStyle(.graphical)
                    .tint(XPendoTheme.accentTeal)
                }

                LabeledField(title: AppLocalization.string("addExpense.field.note"), icon: "note.text") {
                    TextField(
                        AppLocalization.string("addExpense.placeholder.note"),
                        text: $viewModel.note,
                        axis: .vertical
                    )
                    .lineLimit(3, reservesSpace: true)
                    .focused($focusedField, equals: .note)
                }
            }
        }
    }

    // Category seçimi SwiftData'dan gelen seed edilmiş category kayıtlarıyla yapılır.
    private var categorySection: some View {
        LabeledField(title: AppLocalization.string("addExpense.field.category"), icon: "tag") {
            if categories.isEmpty {
                Text(AppLocalization.string("addExpense.empty.noCategories"))
                    .font(.subheadline)
                    .foregroundStyle(XPendoTheme.secondaryText)
            } else {
                Menu {
                    ForEach(categories) { category in
                        Button {
                            viewModel.selectedCategory = category
                        } label: {
                            Label(CategoryLocalization.localizedName(for: category.name), systemImage: category.icon)
                        }
                    }
                } label: {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(selectedCategoryColor)
                            .frame(width: 12, height: 12)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(selectedCategoryName)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(XPendoTheme.primaryText)

                            Text(AppLocalization.string("addExpense.caption.choosePreparedCategory"))
                                .font(.caption)
                                .foregroundStyle(XPendoTheme.secondaryText)
                        }

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(XPendoTheme.secondaryText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(XPendoTheme.inputBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // Save butonu ViewModel'in add veya edit kararını çalıştırır.
    private var saveSection: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(AppLocalization.string("common.save"))
                    .font(.headline)
                    .foregroundStyle(XPendoTheme.primaryText)

                Button(action: saveExpense) {
                    HStack {
                        Text(viewModel.saveButtonTitle)
                            .font(.headline)

                        Spacer()

                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title3)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .frame(height: 58)
                    .frame(maxWidth: .infinity)
                    .background(
                        categories.isEmpty ? XPendoTheme.secondaryText : XPendoTheme.accentTeal,
                        in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                    )
                }
                .buttonStyle(.plain)
                .disabled(categories.isEmpty)

                Text(saveFootnote)
                    .font(.subheadline)
                    .foregroundStyle(XPendoTheme.secondaryText)
            }
        }
    }

    // Settings içindeki currency tercihi yoksa desteklenen varsayılan currency seçilir.
    private var currencyCode: String {
        CurrencyConverter.supportedCurrencyCode(from: settings.first?.currencyCode)
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var expenseFormSyncKey: String {
        "\(categories.count)-\(currencyCode)-\(expenseToEdit?.id.uuidString ?? "new")"
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var selectedCategoryColor: Color {
        if let colorString = viewModel.selectedCategory?.color,
           let color = Color(hexString: colorString) {
            return color
        }

        return XPendoTheme.accentTeal
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var selectedCategoryName: String {
        // Gerekli data eksikse erken çıkış yapar.
        guard let selectedCategory = viewModel.selectedCategory else {
            return AppLocalization.string("addExpense.placeholder.selectCategory")
        }

        return CategoryLocalization.localizedName(for: selectedCategory.name)
    }

    // Binding wrapper, optional error state'ini SwiftUI alert isPresented değerine çevirir.
    private var saveErrorBinding: Binding<Bool> {
        Binding(
            get: { saveErrorMessage != nil },
            set: { newValue in
                if !newValue {
                    saveErrorMessage = nil
                }
            }
        )
    }

    // Validation geçtikten sonra yeni user data kaydeder.
    private var saveFootnote: String {
        if expenseToEdit == nil {
            return AppLocalization.string("addExpense.footnote.savedNew")
        }

        return AppLocalization.string("addExpense.footnote.savedEdited")
    }

    // Save akışı async tutulur; başarılı kayıt sonrası notification schedule yenilenir ve sheet kapanır.
    private func saveExpense() {
        // Bu synchronous context içinden async work çalıştırır.
        Task {
            // Async operation tamamlanana kadar bekler.
            await saveExpenseFlow()
        }
    }

    @MainActor
    // Validation geçtikten sonra yeni user data kaydeder.
    private func saveExpenseFlow() async {
        // Error fırlatabilecek işi başlatır.
        do {
            try viewModel.saveExpense(
                in: modelContext,
                categories: categories,
                inputCurrencyCode: currencyCode
            )

            if viewModel.validationMessage == nil {
                // Async operation tamamlanana kadar bekler.
                try await NotificationSyncService.refresh(using: modelContext)
                dismiss()
            }
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }

    // App’in bu bölümünde kullanılan supported value listesini tanımlar.
    private enum Field {
        case title
        case amount
        case note
    }
}

#Preview {
    AddExpenseView()
        .modelContainer(XPendoModelContainer.shared)
}

// App tarafından kullanılan lightweight value type tanımlar.
private struct ReceiptSuggestionBanner: View {
    let message: String

    // Bu view için görünen SwiftUI layout’unu kurar.
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(XPendoTheme.accentTeal)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(XPendoTheme.primaryText)

            Spacer()
        }
        .padding(16)
        .background(XPendoTheme.surfaceBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(XPendoTheme.accentTeal.opacity(0.18), lineWidth: 1)
        }
    }
}

// App tarafından kullanılan lightweight value type tanımlar.
private struct LabeledField<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    // Bu value’yu çalışmak için ihtiyaç duyduğu data ile hazırlar.
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    // Bu view için görünen SwiftUI layout’unu kurar.
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(XPendoTheme.accentTeal.opacity(0.12))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: icon)
                            .foregroundStyle(XPendoTheme.accentTeal)
                    }

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(XPendoTheme.primaryText)
            }

            content
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(XPendoTheme.inputBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}

// App tarafından kullanılan lightweight value type tanımlar.
private struct ValidationBanner: View {
    let message: String

    // Bu view için görünen SwiftUI layout’unu kurar.
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(XPendoTheme.coral)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(XPendoTheme.primaryText)

            Spacer()
        }
        .padding(16)
        .background(XPendoTheme.surfaceBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(XPendoTheme.coral.opacity(0.18), lineWidth: 1)
        }
    }
}
