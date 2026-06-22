import SwiftUI

// BudgetStatusCard, Budget ekranında tek category için limit inputu ve kullanım özetini gösterir.
// Save/reset aksiyonlarını callback olarak alır; SwiftData işlemi ViewModel tarafında yapılır.
struct BudgetStatusCard: View {
    let entry: BudgetCategoryEntry
    @Binding var amountText: String
    let currencyCode: String
    let saveButtonTitle: String
    let isResetEnabled: Bool
    let validationMessage: String?
    let onSave: () -> Void
    let onReset: () -> Void

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 14) {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(statusColor.opacity(0.12))
                        .frame(width: 52, height: 52)
                        .overlay {
                            Image(systemName: entry.categoryIcon)
                                .font(.headline)
                                .foregroundStyle(statusColor)
                        }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(CategoryLocalization.localizedName(for: entry.categoryName))
                            .font(.headline)
                            .foregroundStyle(XPendoTheme.primaryText)

                        Text(statusDescription)
                            .font(.subheadline)
                            .foregroundStyle(XPendoTheme.secondaryText)
                    }

                    Spacer()

                    Text(statusLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(statusColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(statusColor.opacity(0.12), in: Capsule())
                }

                HStack(alignment: .bottom, spacing: 12) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(AppLocalization.string("addExpense.field.amount"))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(XPendoTheme.secondaryText)

                        HStack(spacing: 12) {
                            TextField("0.00", text: $amountText)
                                .keyboardType(.decimalPad)

                            Text(currencyCode)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(XPendoTheme.accentTeal)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(XPendoTheme.accentTeal.opacity(0.12), in: Capsule())
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(XPendoTheme.inputBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }

                    Spacer(minLength: 0)

                    VStack(spacing: 8) {
                        Button(action: onSave) {
                            Text(saveButtonTitle)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(width: 96, height: 50)
                                .background(XPendoTheme.accentTeal, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .buttonStyle(.plain)

                        Button(action: onReset) {
                            Text(AppLocalization.string("common.reset"))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(XPendoTheme.primaryText)
                                .frame(width: 96, height: 34)
                                .background(XPendoTheme.inputBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .disabled(!isResetEnabled)
                        .opacity(isResetEnabled ? 1 : 0.45)
                    }
                }

                if let validationMessage {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(XPendoTheme.coral)

                        Text(validationMessage)
                            .font(.caption)
                            .foregroundStyle(XPendoTheme.primaryText)
                    }
                    .padding(12)
                    .background(XPendoTheme.surfaceBackground, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(XPendoTheme.coral.opacity(0.16), lineWidth: 1)
                    }
                }

                if entry.hasBudget {
                    VStack(spacing: 10) {
                        BudgetUsageProgressBar(
                            progress: entry.cappedProgress,
                            accentColor: statusColor
                        )

                        HStack {
                            Text(AppLocalization.format("budget.status.progressDetail", Int((entry.progress * 100).rounded())))
                            Spacer()
                            Text(CurrencyConverter.formatFromTRY(entry.limitAmount ?? 0, to: currencyCode))
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(XPendoTheme.secondaryText)
                    }
                } else {
                    Text("No budget saved for this month yet. Enter an amount above to start tracking this category.")
                        .font(.caption)
                        .foregroundStyle(XPendoTheme.secondaryText)
                        .padding(14)
                        .background(XPendoTheme.inputBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                }

                HStack(spacing: 12) {
                    BudgetStatColumn(
                        title: AppLocalization.string("budget.spent"),
                        value: CurrencyConverter.formatFromTRY(entry.spentAmount, to: currencyCode),
                        accentColor: statusColor
                    )

                    BudgetStatColumn(
                        title: entry.isOverBudget ? AppLocalization.string("budget.overBy") : AppLocalization.string("budget.remaining"),
                        value: remainingValue,
                        accentColor: entry.isOverBudget ? XPendoTheme.coral : XPendoTheme.freshGreen
                    )

                    BudgetStatColumn(
                        title: AppLocalization.string("budget.limit"),
                        value: limitValue,
                        accentColor: XPendoTheme.softPurple
                    )
                }
            }
        }
    }

    // Status label, budget var/yok ve limit aşımı durumunu kullanıcıya kısa şekilde anlatır.
    private var statusLabel: String {
        if !entry.hasBudget {
            return AppLocalization.string("budget.status.ready")
        }

        return entry.isOverBudget ? AppLocalization.string("budget.status.over") : AppLocalization.string("budget.status.tracked")
    }

    private var statusDescription: String {
        if !entry.hasBudget {
            return AppLocalization.string("budget.statusDescription.notSet")
        }

        return entry.isOverBudget
            ? AppLocalization.string("budget.statusDescription.exceeded")
            : AppLocalization.string("budget.statusDescription.onTrack")
    }

    // Kalan veya aşan tutar display currency formatına çevrilerek gösterilir.
    private var remainingValue: String {
        guard let remainingAmount = entry.remainingAmount else {
            return AppLocalization.string("common.notSet")
        }

        return CurrencyConverter.formatFromTRY(abs(remainingAmount), to: currencyCode)
    }

    private var limitValue: String {
        guard let limitAmount = entry.limitAmount else {
            return AppLocalization.string("common.notSet")
        }

        return CurrencyConverter.formatFromTRY(limitAmount, to: currencyCode)
    }

    private var statusColor: Color {
        if entry.isOverBudget {
            return XPendoTheme.coral
        }

        return Color(hexString: entry.colorHex) ?? XPendoTheme.accentTeal
    }
}

// BudgetUsageProgressBar, harcama/limit oranını görsel progress olarak gösterir.
private struct BudgetUsageProgressBar: View {
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
        .frame(height: 10)
    }
}

// BudgetStatColumn, spent/remaining/limit gibi küçük budget metriklerini tekrar kullanılabilir gösterir.
private struct BudgetStatColumn: View {
    let title: String
    let value: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(XPendoTheme.secondaryText)

            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(XPendoTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Capsule()
                .fill(accentColor.opacity(0.24))
                .frame(width: 32, height: 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(XPendoTheme.inputBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
