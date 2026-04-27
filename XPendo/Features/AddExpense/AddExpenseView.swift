import SwiftUI
import SwiftData

struct AddExpenseView: View {
    let expenseToEdit: Expense?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Category.name) private var categories: [Category]
    @Query private var settings: [AppSettings]

    @FocusState private var focusedField: Field?
    @State private var viewModel: AddExpenseViewModel
    @State private var saveErrorMessage: String?

    init(expenseToEdit: Expense? = nil) {
        self.expenseToEdit = expenseToEdit
        _viewModel = State(initialValue: AddExpenseViewModel(expenseToEdit: expenseToEdit))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                entryFormSection

                if let validationMessage = viewModel.validationMessage {
                    ValidationBanner(message: validationMessage)
                }

                saveSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .background(XPendoTheme.background.ignoresSafeArea())
        .task(id: expenseFormSyncKey) {
            viewModel.prepareForm(categories: categories, displayCurrencyCode: currencyCode)
        }
        .alert("addExpense.alert.saveFailed.title", isPresented: saveErrorBinding) {
            Button("common.ok", role: .cancel) { }
        } message: {
            Text(saveErrorMessage ?? AppLocalization.string("common.tryAgain"))
        }
    }

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

    private var entryFormSection: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 18) {
                Text("addExpense.section.details")
                    .font(.headline)
                    .foregroundStyle(XPendoTheme.primaryText)

                categorySection

                LabeledField(title: AppLocalization.string("addExpense.field.title"), icon: "textformat") {
                    TextField("addExpense.placeholder.title", text: $viewModel.title)
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
                        "addExpense.field.expenseDate",
                        selection: $viewModel.date,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .datePickerStyle(.graphical)
                    .tint(XPendoTheme.accentTeal)
                }

                LabeledField(title: AppLocalization.string("addExpense.field.note"), icon: "note.text") {
                    TextField(
                        "addExpense.placeholder.note",
                        text: $viewModel.note,
                        axis: .vertical
                    )
                    .lineLimit(3, reservesSpace: true)
                    .focused($focusedField, equals: .note)
                }
            }
        }
    }

    private var categorySection: some View {
        LabeledField(title: AppLocalization.string("addExpense.field.category"), icon: "tag") {
            if categories.isEmpty {
                Text("addExpense.empty.noCategories")
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

                            Text("addExpense.caption.choosePreparedCategory")
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

    private var saveSection: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("common.save")
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

    private var currencyCode: String {
        CurrencyConverter.supportedCurrencyCode(from: settings.first?.currencyCode)
    }

    private var expenseFormSyncKey: String {
        "\(categories.count)-\(currencyCode)-\(expenseToEdit?.id.uuidString ?? "new")"
    }

    private var selectedCategoryColor: Color {
        if let colorString = viewModel.selectedCategory?.color,
           let color = Color(hexString: colorString) {
            return color
        }

        return XPendoTheme.accentTeal
    }

    private var selectedCategoryName: String {
        guard let selectedCategory = viewModel.selectedCategory else {
            return AppLocalization.string("addExpense.placeholder.selectCategory")
        }

        return CategoryLocalization.localizedName(for: selectedCategory.name)
    }

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

    private var saveFootnote: String {
        if expenseToEdit == nil {
            return AppLocalization.string("addExpense.footnote.savedNew")
        }

        return AppLocalization.string("addExpense.footnote.savedEdited")
    }

    private func saveExpense() {
        Task {
            await saveExpenseFlow()
        }
    }

    @MainActor
    private func saveExpenseFlow() async {
        do {
            try viewModel.saveExpense(
                in: modelContext,
                categories: categories,
                inputCurrencyCode: currencyCode
            )

            if viewModel.validationMessage == nil {
                try await NotificationSyncService.refresh(using: modelContext)
                dismiss()
            }
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }

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

private struct LabeledField<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

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

private struct ValidationBanner: View {
    let message: String

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
