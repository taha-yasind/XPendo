import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Xpendo")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(XPendoTheme.primaryText)

                        Text("A bright, structured foundation for personal expense tracking.")
                            .font(.subheadline)
                            .foregroundStyle(XPendoTheme.secondaryText)
                    }

                    Spacer()

                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.headline)
                            .foregroundStyle(XPendoTheme.primaryText)
                            .frame(width: 46, height: 46)
                            .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .strokeBorder(XPendoTheme.cardBorder, lineWidth: 1)
                            }
                            .shadow(color: XPendoTheme.cardShadow, radius: 16, x: 0, y: 10)
                    }
                    .buttonStyle(.plain)
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Monthly Overview")
                                .font(.headline)
                                .foregroundStyle(XPendoTheme.primaryText)

                            Spacer()

                            Text("Phase 1")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(XPendoTheme.accentTeal)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(XPendoTheme.accentTeal.opacity(0.12), in: Capsule())
                        }

                        SkeletonLine(width: 180, height: 38)

                        Text("This hero area is reserved for the dashboard summary that will be implemented later.")
                            .font(.subheadline)
                            .foregroundStyle(XPendoTheme.secondaryText)

                        HStack(spacing: 12) {
                            HomeMetricCard(
                                title: "Today's Spending",
                                accentColor: XPendoTheme.accentTeal
                            )

                            HomeMetricCard(
                                title: "Remaining Budget",
                                accentColor: XPendoTheme.freshGreen
                            )
                        }
                    }
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Top Categories")
                            .font(.headline)
                            .foregroundStyle(XPendoTheme.primaryText)

                        HStack(spacing: 10) {
                            CategoryPill(title: "Food", color: XPendoTheme.accentTeal)
                            CategoryPill(title: "Transport", color: XPendoTheme.housingGreen)
                            CategoryPill(title: "Shopping", color: XPendoTheme.coral)
                        }

                        VStack(spacing: 14) {
                            CategoryPlaceholderRow(color: XPendoTheme.accentTeal)
                            CategoryPlaceholderRow(color: XPendoTheme.housingGreen)
                            CategoryPlaceholderRow(color: XPendoTheme.coral)
                        }
                    }
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Recent Transactions")
                            .font(.headline)
                            .foregroundStyle(XPendoTheme.primaryText)

                        VStack(spacing: 16) {
                            RecentTransactionPlaceholder(accentColor: XPendoTheme.accentTeal)
                            RecentTransactionPlaceholder(accentColor: XPendoTheme.softPurple)
                            RecentTransactionPlaceholder(accentColor: XPendoTheme.coral)
                        }
                    }
                }

                PlaceholderCard(
                    title: "Budget Preview Area",
                    systemImage: "gauge.with.needle",
                    description: "The home screen already reserves space for future budget warnings and progress highlights.",
                    accentColor: XPendoTheme.coral
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
        HomeView()
    }
    .background(XPendoTheme.background)
}

private struct HomeMetricCard: View {
    let title: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(XPendoTheme.primaryText)

            SkeletonLine(width: 72, height: 22)
            SkeletonLine(width: 96, height: 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct CategoryPill: View {
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(XPendoTheme.primaryText)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.12), in: Capsule())
    }
}

private struct CategoryPlaceholderRow: View {
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 8) {
                SkeletonLine(width: 110)
                SkeletonLine(width: 150, height: 10)
            }

            Spacer()

            SkeletonLine(width: 54)
        }
    }
}

private struct RecentTransactionPlaceholder: View {
    let accentColor: Color

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(accentColor.opacity(0.14))
                .frame(width: 46, height: 46)
                .overlay {
                    Image(systemName: "creditcard.fill")
                        .foregroundStyle(accentColor)
                }

            VStack(alignment: .leading, spacing: 8) {
                SkeletonLine(width: 120)
                SkeletonLine(width: 90, height: 10)
            }

            Spacer()

            SkeletonLine(width: 56)
        }
    }
}
