import SwiftUI

struct ExpenseRowCard: View {
    let expense: Expense
    let currencyCode: String
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 14) {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(categoryColor.opacity(0.14))
                        .frame(width: 52, height: 52)
                        .overlay {
                            Image(systemName: expense.category.icon)
                                .font(.headline)
                                .foregroundStyle(categoryColor)
                        }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(expense.title)
                            .font(.headline)
                            .foregroundStyle(XPendoTheme.primaryText)

                        HStack(spacing: 8) {
                            Text(expense.category.name)
                            Text("•")
                            Text(expense.date.formatted(date: .abbreviated, time: .omitted))
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
                            Button("Edit", systemImage: "pencil", action: onEdit)
                            Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.headline)
                                .foregroundStyle(XPendoTheme.secondaryText)
                                .frame(width: 34, height: 34)
                                .background(XPendoTheme.background, in: Circle())
                        }
                        .buttonStyle(.plain)

                        Text(expense.amount, format: .currency(code: currencyCode))
                            .font(.headline.weight(.bold))
                            .foregroundStyle(XPendoTheme.primaryText)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }
    }

    private var categoryColor: Color {
        Color(hexString: expense.category.color) ?? XPendoTheme.accentTeal
    }
}
