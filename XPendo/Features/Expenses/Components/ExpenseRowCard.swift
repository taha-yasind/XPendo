/*
 DOSYA: ExpenseRowCard.swift
 AMAÇ: Category, amount ve destekleyici detaylarla tek bir expense row gösterir. Expense listelerinde tekrarlanan item olarak kullanılır.
 KULLANAN: ExpensesView, HomeView ve Expense değerleri gösteren listeler tarafından kullanılır.
*/
import SwiftUI

// ExpenseRowCard, Expenses ekranında tek bir Expense kaydını gösteren reusable karttır.
// Edit ve delete aksiyonlarını callback olarak alır, persistence işlemi yapmaz.
struct ExpenseRowCard: View {
    let expense: Expense
    let currencyCode: String
    let onEdit: () -> Void
    let onDelete: () -> Void

    // Bu view için görünen SwiftUI layout’unu kurar.
    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 14) {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(categoryColor.opacity(0.14))
                        .frame(width: 52, height: 52)
                        .overlay {
                            Image(systemName: expense.categoryIcon)
                                .font(.headline)
                                .foregroundStyle(categoryColor)
                        }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(expense.title)
                            .font(.headline)
                            .foregroundStyle(XPendoTheme.primaryText)

                        HStack(spacing: 8) {
                            Text(CategoryLocalization.localizedName(for: expense.categoryName))
                            Text("•")
                            Text(expense.date.formatted(.dateTime.day().month(.abbreviated).year().locale(AppLocalization.locale)))
                        }
                        .font(.caption)
                        .foregroundStyle(XPendoTheme.secondaryText)

                        if let note = expense.note, !note.isEmpty {
                            Text(note)
                                .font(.subheadline)
                                .foregroundStyle(XPendoTheme.secondaryText)
                                .lineLimit(2)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 10) {
                        Menu {
                            Button(AppLocalization.string("expenses.menu.edit"), systemImage: "pencil", action: onEdit)
                            Button(AppLocalization.string("common.delete"), systemImage: "trash", role: .destructive, action: onDelete)
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.headline)
                                .foregroundStyle(XPendoTheme.secondaryText)
                                .frame(width: 34, height: 34)
                                .background(XPendoTheme.inputBackground, in: Circle())
                        }
                        .buttonStyle(.plain)

                        Text(CurrencyConverter.formatFromTRY(expense.amount, to: currencyCode))
                            .font(.headline.weight(.bold))
                            .foregroundStyle(XPendoTheme.primaryText)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var categoryColor: Color {
        Color(hexString: expense.categoryColor) ?? XPendoTheme.accentTeal
    }
}
