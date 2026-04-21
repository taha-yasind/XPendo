import SwiftUI

struct ExpensesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ScreenHeader(
                    title: "Expenses",
                    subtitle: "A card-based placeholder list prepared for the real expense management flow."
                )

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Planned Filters")
                            .font(.headline)
                            .foregroundStyle(XPendoTheme.primaryText)

                        HStack(spacing: 10) {
                            FilterChip(title: "All", isHighlighted: true)
                            FilterChip(title: "This Month")
                            FilterChip(title: "Category")
                        }

                        Text("Filtering is intentionally visual-only in Phase 1 and becomes functional later.")
                            .font(.subheadline)
                            .foregroundStyle(XPendoTheme.secondaryText)
                    }
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Expense List Skeleton")
                            .font(.headline)
                            .foregroundStyle(XPendoTheme.primaryText)

                        VStack(spacing: 16) {
                            ExpensePlaceholderRow(color: XPendoTheme.accentTeal)
                            ExpensePlaceholderRow(color: XPendoTheme.coral)
                            ExpensePlaceholderRow(color: XPendoTheme.housingGreen)
                            ExpensePlaceholderRow(color: XPendoTheme.softPurple)
                        }
                    }
                }

                PlaceholderCard(
                    title: "Empty State Prepared",
                    systemImage: "tray.fill",
                    description: "The list already has room for a clean empty-state treatment once real data handling starts in Phase 4.",
                    accentColor: XPendoTheme.freshGreen
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 130)
        }
        .background(XPendoTheme.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        ExpensesView()
    }
    .background(XPendoTheme.background)
}

private struct ScreenHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(XPendoTheme.primaryText)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(XPendoTheme.secondaryText)
        }
    }
}

private struct FilterChip: View {
    let title: String
    var isHighlighted: Bool = false

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(isHighlighted ? .white : XPendoTheme.primaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                isHighlighted ? XPendoTheme.accentTeal : XPendoTheme.placeholder.opacity(0.55),
                in: Capsule()
            )
    }
}

private struct ExpensePlaceholderRow: View {
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(color.opacity(0.14))
                .frame(width: 50, height: 50)
                .overlay {
                    Circle()
                        .fill(color)
                        .frame(width: 12, height: 12)
                }

            VStack(alignment: .leading, spacing: 8) {
                SkeletonLine(width: 120)
                SkeletonLine(width: 80, height: 10)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                SkeletonLine(width: 62)
                SkeletonLine(width: 40, height: 10)
            }
        }
        .padding(16)
        .background(XPendoTheme.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
