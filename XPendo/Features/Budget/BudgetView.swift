import SwiftData
import SwiftUI

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
        .background(XPendoTheme.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task(id: budgetSyncKey) {
            viewModel.prepare(categories: categories, budgets: budgets, displayCurrencyCode: currencyCode)
        }
        .alert("Budget action could not be completed", isPresented: saveErrorBinding) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(saveErrorMessage ?? "Please try again.")
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

    private var monthData: BudgetMonthData {
        viewModel.makeMonthData(budgets: budgets, expenses: expenses)
    }

    private var currencyCode: String {
        CurrencyConverter.supportedCurrencyCode(from: settings.first?.currencyCode)
    }

    private var categoryEntries: [BudgetCategoryEntry] {
        viewModel
            .makeCategoryEntries(categories: categories, budgets: budgets, expenses: expenses)
            .sorted(by: sortCategoryEntriesForDisplay)
    }

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

                Text("\(categories.count) total")
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

    private func moveToPreviousMonth() {
        viewModel.moveMonth(by: -1)
    }

    private func moveToNextMonth() {
        viewModel.moveMonth(by: 1)
    }

    private func draftBinding(for categoryID: UUID) -> Binding<String> {
        Binding(
            get: { viewModel.draftAmount(for: categoryID) },
            set: { newValue in
                viewModel.updateDraftAmount(newValue, for: categoryID)
            }
        )
    }

    private func saveBudget(for categoryID: UUID) {
        Task {
            await saveBudgetFlow(for: categoryID)
        }
    }

    private func resetBudget(for categoryID: UUID) {
        Task {
            await resetBudgetFlow(for: categoryID)
        }
    }

    private func requestResetConfirmation(for categoryID: UUID) {
        pendingResetCategoryID = categoryID
        isResetSheetPresented = true
    }

    private func confirmResetBudget() {
        guard let categoryID = pendingResetCategoryID else {
            return
        }

        pendingResetCategoryID = nil
        resetBudget(for: categoryID)
    }

    private func sortCategoryEntriesForDisplay(_ lhs: BudgetCategoryEntry, _ rhs: BudgetCategoryEntry) -> Bool {
        let lhsIsOther = lhs.categoryName.trimmingCharacters(in: .whitespacesAndNewlines).localizedCaseInsensitiveCompare("Other") == .orderedSame
        let rhsIsOther = rhs.categoryName.trimmingCharacters(in: .whitespacesAndNewlines).localizedCaseInsensitiveCompare("Other") == .orderedSame

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
            return "This action will clear the budget amount for this category in the selected month."
        }

        return "This action will clear the budget amount for \(category.name) in \(viewModel.selectedMonthTitle)."
    }

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
                        Text("Cancel")
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
                        Text("Reset")
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
                        title: "Spent",
                        value: CurrencyConverter.formatFromTRY(monthData.totalSpent, to: currencyCode),
                        accentColor: XPendoTheme.softPurple
                    )

                    BudgetSummaryTile(
                        title: monthData.totalRemaining >= 0 ? "Remaining" : "Over by",
                        value: CurrencyConverter.formatFromTRY(abs(monthData.totalRemaining), to: currencyCode),
                        accentColor: monthData.totalRemaining >= 0 ? XPendoTheme.freshGreen : XPendoTheme.coral
                    )

                    BudgetSummaryTile(
                        title: "Tracked",
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
                        Text("\(monthData.trackedBudgetCount) categories tracked")
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
            return "Set a budget to start tracking"
        }

        return "\(Int((monthData.totalProgress * 100).rounded()))% used"
    }

    private var warningText: String {
        if monthData.overspentCount == 1 {
            return "1 category is already above its monthly limit."
        }

        return "\(monthData.overspentCount) categories are already above their monthly limits."
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
                title: "No Categories Available",
                description: "Budget tracking becomes available when categories exist for monthly planning.",
                accentColor: XPendoTheme.accentTeal
            )
        }
    }
}
