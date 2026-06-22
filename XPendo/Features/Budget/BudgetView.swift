import SwiftData
import SwiftUI

// BudgetView, category bazlı aylık harcama limitlerini yönetir.
// ViewModel hesaplama ve save/reset işlemlerini yaparken bu View liste ve confirmation sheet akışını sunar.
struct BudgetView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Category.name) private var categories: [Category]
    @Query(
        sort: [
            SortDescriptor(\Expense.date, order: .reverse),
            SortDescriptor(\Expense.createdAt, order: .reverse)
        ]
    ) private var expenses: [Expense]
    @Query(
        sort: [
            SortDescriptor(\Budget.year, order: .reverse),
            SortDescriptor(\Budget.month, order: .reverse),
            SortDescriptor(\Budget.limitAmount, order: .reverse)
        ]
    ) private var budgets: [Budget]
    @Query private var settings: [AppSettings]

    @State private var viewModel = BudgetViewModel()
    @State private var saveErrorMessage: String?
    @State private var pendingResetCategoryID: UUID?
    @State private var isResetSheetPresented = false
    @FocusState private var focusedBudgetCategoryID: UUID?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                BudgetHeader()
                BudgetMonthOverviewCard(
                    monthData: monthData,
                    selectedMonthTitle: viewModel.selectedMonthTitle,
                    currencyCode: currencyCode,
                    onPreviousMonth: moveToPreviousMonth,
                    onNextMonth: moveToNextMonth
                )
                budgetListSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 130)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(
            XPendoTheme.background
                .ignoresSafeArea()
                .onTapGesture {
                    dismissKeyboard()
                }
        )
        .toolbar(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button(AppLocalization.string("common.done")) {
                    dismissKeyboard()
                }
            }
        }
        .task(id: budgetSyncKey) {
            // Budget, category veya currency değiştiğinde draft limit alanları güncel veriye göre hazırlanır.
            viewModel.prepare(categories: categories, budgets: budgets, displayCurrencyCode: currencyCode)
        }
        .alert("budget.alert.actionFailed.title", isPresented: saveErrorBinding) {
            Button("common.ok", role: .cancel) { }
        } message: {
            Text(saveErrorMessage ?? AppLocalization.string("common.tryAgain"))
        }
        .sheet(isPresented: $isResetSheetPresented, onDismiss: {
            pendingResetCategoryID = nil
        }) {
            ResetBudgetConfirmationSheet(
                message: resetConfirmationMessage,
                onConfirm: {
                    isResetSheetPresented = false
                    confirmResetBudget()
                },
                onCancel: {
                    isResetSheetPresented = false
                    pendingResetCategoryID = nil
                }
            )
            .presentationDetents([.height(240)])
            .presentationDragIndicator(.visible)
            .presentationBackground(XPendoTheme.background)
        }
    }

    // Seçili ayın budget özeti ViewModel tarafından SwiftData verilerinden hesaplanır.
    private var monthData: BudgetMonthData {
        viewModel.makeMonthData(budgets: budgets, expenses: expenses)
    }

    private var currencyCode: String {
        CurrencyConverter.supportedCurrencyCode(from: settings.first?.currencyCode)
    }

    // Category listesi, budget durumu ve harcama toplamlarıyla birleştirilerek ekrana verilir.
    private var categoryEntries: [BudgetCategoryEntry] {
        viewModel
            .makeCategoryEntries(categories: categories, budgets: budgets, expenses: expenses)
            .sorted(by: sortCategoryEntriesForDisplay)
    }

    // SwiftUI task'in ne zaman yeniden çalışacağını belirleyen senkronizasyon anahtarıdır.
    private var budgetSyncKey: String {
        let budgetSignature = budgets
            .map { "\($0.id.uuidString)-\($0.limitAmount)-\($0.month)-\($0.year)" }
            .joined(separator: "|")

        return "\(viewModel.selectedMonth.timeIntervalSinceReferenceDate)-\(categories.count)-\(budgetSignature)-\(currencyCode)"
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

    @ViewBuilder
    private var budgetListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Categories")
                    .font(.headline)
                    .foregroundStyle(XPendoTheme.primaryText)

                Spacer()

                Text(AppLocalization.format("budget.section.categoriesCount", categories.count))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(XPendoTheme.secondaryText)
            }

            Text("Enter each category amount directly from the list below for \(viewModel.selectedMonthTitle).")
                .font(.subheadline)
                .foregroundStyle(XPendoTheme.secondaryText)

            if categories.isEmpty {
                BudgetEmptyState()
            } else {
                VStack(spacing: 16) {
                    ForEach(categoryEntries) { entry in
                        BudgetStatusCard(
                            entry: entry,
                            amountText: draftBinding(for: entry.categoryID),
                            currencyCode: currencyCode,
                            saveButtonTitle: viewModel.saveButtonTitle(for: entry.categoryID, budgets: budgets),
                            isResetEnabled: viewModel.isResetEnabled(for: entry.categoryID, budgets: budgets),
                            validationMessage: viewModel.validationMessage(for: entry.categoryID),
                            focusedCategoryID: $focusedBudgetCategoryID,
                            onSave: {
                                saveBudget(for: entry.categoryID)
                            },
                            onReset: {
                                requestResetConfirmation(for: entry.categoryID)
                            }
                        )
                    }
                }
            }
        }
    }

    private func dismissKeyboard() {
        focusedBudgetCategoryID = nil
    }

    private func moveToPreviousMonth() {
        dismissKeyboard()
        viewModel.moveMonth(by: -1)
    }

    private func moveToNextMonth() {
        dismissKeyboard()
        viewModel.moveMonth(by: 1)
    }

    // Her category satırındaki TextField, ViewModel'in draft sözlüğüne binding ile bağlanır.
    private func draftBinding(for categoryID: UUID) -> Binding<String> {
        Binding(
            get: { viewModel.draftAmount(for: categoryID) },
            set: { newValue in
                viewModel.updateDraftAmount(newValue, for: categoryID)
            }
        )
    }

    // Save aksiyonu async flow'a taşınır; işlem sonrası notification schedule yenilenir.
    private func saveBudget(for categoryID: UUID) {
        dismissKeyboard()
        Task {
            await saveBudgetFlow(for: categoryID)
        }
    }

    private func resetBudget(for categoryID: UUID) {
        dismissKeyboard()
        Task {
            await resetBudgetFlow(for: categoryID)
        }
    }

    // Reset doğrudan yapılmaz; önce confirmation sheet ile kullanıcıdan onay alınır.
    private func requestResetConfirmation(for categoryID: UUID) {
        dismissKeyboard()
        pendingResetCategoryID = categoryID
        isResetSheetPresented = true
    }

    // Reset onaylandıktan sonra seçili category için Budget kaydı silinir.
    private func confirmResetBudget() {
        guard let categoryID = pendingResetCategoryID else {
            return
        }

        pendingResetCategoryID = nil
        resetBudget(for: categoryID)
    }

    // "Other" category en sona alınır, diğerleri alfabetik gösterilir.
    private func sortCategoryEntriesForDisplay(_ lhs: BudgetCategoryEntry, _ rhs: BudgetCategoryEntry) -> Bool {
        let lhsIsOther = CategoryLocalization.isOther(lhs.categoryName)
        let rhsIsOther = CategoryLocalization.isOther(rhs.categoryName)

        if lhsIsOther != rhsIsOther {
            return !lhsIsOther && rhsIsOther
        }

        return lhs.categoryName.localizedCaseInsensitiveCompare(rhs.categoryName) == .orderedAscending
    }

    private var resetConfirmationMessage: String {
        guard
            let categoryID = pendingResetCategoryID,
            let category = categories.first(where: { $0.id == categoryID })
        else {
            return AppLocalization.string("budget.reset.message.fallback")
        }

        return AppLocalization.format(
            "budget.reset.message.categoryMonth",
            CategoryLocalization.localizedName(for: category.name),
            viewModel.selectedMonthTitle
        )
    }

    // Budget save başarılı olursa budget warning notification'ları yeni limite göre yeniden planlanır.
    @MainActor
    private func saveBudgetFlow(for categoryID: UUID) async {
        guard let category = categories.first(where: { $0.id == categoryID }) else {
            return
        }

        do {
            try viewModel.saveBudget(
                for: category,
                in: modelContext,
                budgets: budgets,
                inputCurrencyCode: currencyCode
            )
            try await NotificationSyncService.refresh(using: modelContext)
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }

    // Budget reset sonrası notification state'i de güncel budget listesine göre yenilenir.
    @MainActor
    private func resetBudgetFlow(for categoryID: UUID) async {
        do {
            try viewModel.resetBudget(
                for: categoryID,
                in: modelContext,
                budgets: budgets
            )
            try await NotificationSyncService.refresh(using: modelContext)
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }
}

// ResetBudgetConfirmationSheet, limit silme aksiyonunu yanlışlıkla yapılmaya karşı onaylatır.
private struct ResetBudgetConfirmationSheet: View {
    let message: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            XPendoTheme.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Text("Reset Budget")
                    .font(.headline)
                    .foregroundStyle(XPendoTheme.primaryText)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(XPendoTheme.secondaryText)

                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text("common.cancel")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(XPendoTheme.primaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(
                                XPendoTheme.inputBackground,
                                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(XPendoTheme.cardBorder, lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)

                    Button(action: onConfirm) {
                        Text("common.reset")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(
                                XPendoTheme.coral,
                                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(18)
            .background(XPendoTheme.surfaceBackground, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(XPendoTheme.cardBorder, lineWidth: 1)
            }
            .shadow(color: XPendoTheme.cardShadow, radius: 18, x: 0, y: 8)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 10)
        }
    }
}

#Preview {
    NavigationStack {
        BudgetView()
            .modelContainer(XPendoModelContainer.shared)
    }
    .background(XPendoTheme.background)
}

private struct BudgetHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Budget")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(XPendoTheme.primaryText)

            Text("Define monthly category limits and compare them with your real spending.")
                .font(.subheadline)
                .foregroundStyle(XPendoTheme.secondaryText)
        }
    }
}

// BudgetMonthOverviewCard, seçili ay için toplam limit/harcama/kalan değerlerini özetler.
private struct BudgetMonthOverviewCard: View {
    let monthData: BudgetMonthData
    let selectedMonthTitle: String
    let currencyCode: String
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Button(action: onPreviousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundStyle(XPendoTheme.primaryText)
                            .frame(width: 42, height: 42)
                            .background(XPendoTheme.inputBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    VStack(spacing: 4) {
                        Text(selectedMonthTitle)
                            .font(.headline)
                            .foregroundStyle(XPendoTheme.primaryText)

                        Text("Monthly budget tracking")
                            .font(.caption)
                            .foregroundStyle(XPendoTheme.secondaryText)
                    }

                    Spacer()

                    Button(action: onNextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.headline)
                            .foregroundStyle(XPendoTheme.primaryText)
                            .frame(width: 42, height: 42)
                            .background(XPendoTheme.inputBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }

                Text(CurrencyConverter.formatFromTRY(monthData.totalLimit, to: currencyCode))
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(XPendoTheme.primaryText)

                Text("Total budget planned for \(selectedMonthTitle).")
                    .font(.subheadline)
                    .foregroundStyle(XPendoTheme.secondaryText)

                HStack(spacing: 12) {
                    BudgetSummaryTile(
                        title: AppLocalization.string("budget.spent"),
                        value: CurrencyConverter.formatFromTRY(monthData.totalSpent, to: currencyCode),
                        accentColor: XPendoTheme.softPurple
                    )

                    BudgetSummaryTile(
                        title: monthData.totalRemaining >= 0 ? AppLocalization.string("budget.remaining") : AppLocalization.string("budget.overBy"),
                        value: CurrencyConverter.formatFromTRY(abs(monthData.totalRemaining), to: currencyCode),
                        accentColor: monthData.totalRemaining >= 0 ? XPendoTheme.freshGreen : XPendoTheme.coral
                    )

                    BudgetSummaryTile(
                        title: AppLocalization.string("budget.tracked"),
                        value: "\(monthData.trackedBudgetCount)",
                        accentColor: XPendoTheme.accentTeal
                    )
                }

                VStack(alignment: .leading, spacing: 10) {
                    BudgetOverviewProgressBar(
                        progress: min(max(monthData.totalProgress, 0), 1),
                        accentColor: monthData.overspentCount > 0 ? XPendoTheme.coral : XPendoTheme.accentTeal
                    )

                    HStack {
                        Text(AppLocalization.format("budget.overview.trackedCount", monthData.trackedBudgetCount))
                        Spacer()
                        Text(progressFootnote)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(XPendoTheme.secondaryText)
                }

                if monthData.overspentCount > 0 {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(XPendoTheme.coral)

                        Text(warningText)
                            .font(.subheadline)
                            .foregroundStyle(XPendoTheme.secondaryText)
                    }
                    .padding(14)
                    .background(XPendoTheme.coral.opacity(0.08), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
            }
        }
    }

    private var progressFootnote: String {
        if monthData.trackedBudgetCount == 0 {
            return AppLocalization.string("budget.progressFootnote.empty")
        }

        return AppLocalization.format("budget.progressFootnote.used", Int((monthData.totalProgress * 100).rounded()))
    }

    private var warningText: String {
        if monthData.overspentCount == 1 {
            return AppLocalization.string("budget.warning.single")
        }

        return AppLocalization.format("budget.warning.multiple", monthData.overspentCount)
    }
}

private struct BudgetSummaryTile: View {
    let title: String
    let value: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(XPendoTheme.secondaryText)

            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(XPendoTheme.primaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct BudgetOverviewProgressBar: View {
    let progress: Double
    let accentColor: Color

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(XPendoTheme.placeholder.opacity(0.6))

                Capsule()
                    .fill(accentColor)
                    .frame(width: proxy.size.width * progress)
            }
        }
        .frame(height: 12)
    }
}

private struct BudgetEmptyState: View {
    var body: some View {
        SurfaceCard {
            StateMessageContent(
                systemImage: "gauge.with.needle",
                title: AppLocalization.string("No Categories Available"),
                description: AppLocalization.string("Budget tracking becomes available when categories exist for monthly planning."),
                accentColor: XPendoTheme.accentTeal
            )
        }
    }
}
