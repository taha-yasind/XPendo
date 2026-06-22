import SwiftUI
import SwiftData

// ExpensesView, kayıtlı harcamaları filtreleme, edit ve delete akışlarıyla listeler.
// Persistence işlemleri ViewModel ve ModelContext üzerinden yapılır.
struct ExpensesView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(
        sort: [
            SortDescriptor(\Expense.date, order: .reverse),
            SortDescriptor(\Expense.createdAt, order: .reverse)
        ]
    ) private var expenses: [Expense]
    @Query(sort: \Category.name) private var categories: [Category]
    @Query private var settings: [AppSettings]

    @State private var viewModel = ExpensesViewModel()
    @State private var deleteErrorMessage: String?

    var body: some View {
        let filtered = filteredExpenses

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                filterSection
                contentSection(filteredExpenses: filtered)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 130)
        }
        .background(XPendoTheme.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: editingExpenseBinding) { expense in
            // Edit flow: seçilen Expense aynı AddExpenseView formuna gönderilir.
            AddExpenseView(expenseToEdit: expense)
        }
        .sheet(item: deleteExpenseBinding) { expense in
            // Delete flow: önce confirmation sheet gösterilir, sonra ModelContext delete çalışır.
            DeleteExpenseSheet(
                expense: expense,
                onDelete: {
                    Task {
                        await deletePendingExpense()
                    }
                },
                onCancel: { viewModel.expensePendingDelete = nil }
            )
            .presentationDetents([.height(182)])
            .presentationDragIndicator(.hidden)
            .presentationBackground(XPendoTheme.surfaceBackground)
        }
        .alert("expenses.alert.deleteFailed.title", isPresented: deleteErrorBinding) {
            Button("common.ok", role: .cancel) { }
        } message: {
            Text(deleteErrorMessage ?? AppLocalization.string("common.tryAgain"))
        }
    }

    // Filtrelenmiş liste ViewModel'den gelir; SwiftData sorgusu sıralı ham veriyi sağlar.
    private var filteredExpenses: [Expense] {
        viewModel.filteredExpenses(from: expenses)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
                Text("expenses.title")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(XPendoTheme.primaryText)

            Text("expenses.subtitle")
                .font(.subheadline)
                .foregroundStyle(XPendoTheme.secondaryText)
        }
    }

    private var filterSection: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("expenses.section.filters")
                    .font(.headline)
                    .foregroundStyle(XPendoTheme.primaryText)

                Menu {
                    ForEach(ExpensesViewModel.TimeFilter.allCases) { filter in
                        Button {
                            viewModel.selectedTimeFilter = filter
                        } label: {
                            if viewModel.selectedTimeFilter == filter {
                                Label(filter.title, systemImage: "checkmark")
                            } else {
                                Text(filter.title)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundStyle(XPendoTheme.accentTeal)

                        Text(viewModel.selectedTimeFilter.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(XPendoTheme.primaryText)

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

                Menu {
                    Button("expenses.filter.allCategories") {
                        viewModel.selectCategory(nil)
                    }

                    ForEach(categories) { category in
                        Button {
                            viewModel.selectCategory(category)
                        } label: {
                            Label(CategoryLocalization.localizedName(for: category.name), systemImage: category.icon)
                        }
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundStyle(XPendoTheme.accentTeal)

                        Text(viewModel.categoryFilterTitle(from: categories))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(XPendoTheme.primaryText)

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

    // Empty state, gerçek veri olmaması ile filtre sonucu eşleşme olmamasını ayrı anlatır.
    @ViewBuilder
    private func contentSection(filteredExpenses: [Expense]) -> some View {
        if expenses.isEmpty {
            ExpenseEmptyState(
                title: AppLocalization.string("expenses.empty.noExpenses.title"),
                description: AppLocalization.string("expenses.empty.noExpenses.description"),
                showsResetButton: false,
                onReset: { }
            )
        } else if filteredExpenses.isEmpty {
            ExpenseEmptyState(
                title: AppLocalization.string("expenses.empty.noMatches.title"),
                description: AppLocalization.string("expenses.empty.noMatches.description"),
                showsResetButton: true,
                onReset: viewModel.resetFilters
            )
        } else {
            LazyVStack(spacing: 16) {
                ForEach(filteredExpenses) { expense in
                    ExpenseRowCard(
                        expense: expense,
                        currencyCode: currencyCode,
                        onEdit: { viewModel.requestEdit(expense) },
                        onDelete: { viewModel.requestDelete(expense) }
                    )
                }
            }
        }
    }

    private var currencyCode: String {
        CurrencyConverter.supportedCurrencyCode(from: settings.first?.currencyCode)
    }

    // Optional edit state'i sheet(item:) için Binding'e dönüştürülür.
    private var editingExpenseBinding: Binding<Expense?> {
        Binding(
            get: { viewModel.expenseBeingEdited },
            set: { viewModel.expenseBeingEdited = $0 }
        )
    }

    // Delete confirmation state'i sheet(item:) tarafından izlenir.
    private var deleteExpenseBinding: Binding<Expense?> {
        Binding(
            get: { viewModel.expensePendingDelete },
            set: { newValue in
                if newValue == nil {
                    viewModel.expensePendingDelete = nil
                }
            }
        )
    }

    private var deleteErrorBinding: Binding<Bool> {
        Binding(
            get: { deleteErrorMessage != nil },
            set: { newValue in
                if !newValue {
                    deleteErrorMessage = nil
                }
            }
        )
    }

    // Delete başarılı olunca budget warning notification'ları da güncel harcama verisine göre yenilenir.
    @MainActor
    private func deletePendingExpense() async {
        do {
            try viewModel.deletePendingExpense(in: modelContext)
            try await NotificationSyncService.refresh(using: modelContext)
        } catch {
            deleteErrorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        ExpensesView()
            .modelContainer(XPendoModelContainer.shared)
    }
    .background(XPendoTheme.background)
}

private struct ExpenseEmptyState: View {
    let title: String
    let description: String
    let showsResetButton: Bool
    let onReset: () -> Void

    var body: some View {
        SurfaceCard {
            StateMessageContent(
                systemImage: "tray.full.fill",
                title: title,
                description: description,
                accentColor: XPendoTheme.freshGreen,
                actionTitle: showsResetButton ? AppLocalization.string("expenses.button.resetFilters") : nil,
                action: showsResetButton ? onReset : nil
            )
        }
    }
}

// DeleteExpenseSheet, silme işlemini presentation-friendly şekilde onaylatan küçük confirmation View'dur.
private struct DeleteExpenseSheet: View {
    let expense: Expense
    let onDelete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 10) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(XPendoTheme.coral.opacity(0.12))
                    .frame(width: 38, height: 38)
                    .overlay {
                        Image(systemName: "trash.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(XPendoTheme.coral)
                    }

                VStack(alignment: .leading, spacing: 3) {
                    Text("expenses.deleteSheet.title")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(XPendoTheme.primaryText)

                    Text(AppLocalization.format("expenses.deleteSheet.message", expense.title))
                        .font(.subheadline)
                        .foregroundStyle(XPendoTheme.secondaryText)
                        .lineLimit(2)
                }
            }

            HStack(spacing: 10) {
                Button("common.cancel", action: onCancel)
                    .buttonStyle(.plain)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(XPendoTheme.primaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(XPendoTheme.inputBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                Button("common.delete", action: onDelete)
                    .buttonStyle(.plain)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(XPendoTheme.coral, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(XPendoTheme.surfaceBackground)
    }
}
