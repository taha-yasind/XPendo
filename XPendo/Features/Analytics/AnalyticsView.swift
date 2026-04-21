import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AnalyticsHeader()

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Category Distribution")
                            .font(.headline)
                            .foregroundStyle(XPendoTheme.primaryText)

                        HStack(alignment: .bottom, spacing: 12) {
                            ChartBar(height: 78, color: XPendoTheme.accentTeal)
                            ChartBar(height: 112, color: XPendoTheme.coral)
                            ChartBar(height: 64, color: XPendoTheme.housingGreen)
                            ChartBar(height: 94, color: XPendoTheme.softPurple)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 12) {
                            LegendBadge(title: "Food", color: XPendoTheme.accentTeal)
                            LegendBadge(title: "Shopping", color: XPendoTheme.coral)
                            LegendBadge(title: "Bills", color: XPendoTheme.softPurple)
                        }
                    }
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Monthly Trend Placeholder")
                            .font(.headline)
                            .foregroundStyle(XPendoTheme.primaryText)

                        HStack(alignment: .bottom, spacing: 10) {
                            TrendBar(height: 36)
                            TrendBar(height: 52)
                            TrendBar(height: 68)
                            TrendBar(height: 44)
                            TrendBar(height: 78)
                        }

                        Text("Charts will become real once expense data and analytics calculations exist in later phases.")
                            .font(.subheadline)
                            .foregroundStyle(XPendoTheme.secondaryText)
                    }
                }

                PlaceholderCard(
                    title: "Insight Summary Area",
                    systemImage: "sparkles",
                    description: "This section is reserved for short, readable insights after real spending data becomes available.",
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
        AnalyticsView()
    }
    .background(XPendoTheme.background)
}

private struct AnalyticsHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Analytics")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(XPendoTheme.primaryText)

            Text("A clear placeholder foundation for future charts and spending insights.")
                .font(.subheadline)
                .foregroundStyle(XPendoTheme.secondaryText)
        }
    }
}

private struct ChartBar: View {
    let height: CGFloat
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(color.opacity(0.7))
            .frame(width: 34, height: height)
    }
}

private struct TrendBar: View {
    let height: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(XPendoTheme.placeholder)
            .frame(maxWidth: .infinity)
            .frame(height: height)
    }
}

private struct LegendBadge: View {
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
