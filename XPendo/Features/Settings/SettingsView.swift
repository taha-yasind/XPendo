import SwiftUI

struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Settings")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(XPendoTheme.primaryText)

                    Text("Accessible from Home now, but intentionally lightweight until the dedicated settings phase.")
                        .font(.subheadline)
                        .foregroundStyle(XPendoTheme.secondaryText)
                }

                SurfaceCard {
                    VStack(spacing: 14) {
                        SettingsPlaceholderRow(title: "Notifications", systemImage: "bell")
                        SettingsPlaceholderRow(title: "Currency", systemImage: "dollarsign.circle")
                        SettingsPlaceholderRow(title: "App Info", systemImage: "info.circle")
                    }
                }

                PlaceholderCard(
                    title: "Phase 9 Content Deferred",
                    systemImage: "clock",
                    description: "Real preferences, reset tools, and configuration controls are intentionally postponed to the Settings phase.",
                    accentColor: XPendoTheme.softPurple
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .background(XPendoTheme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .background(XPendoTheme.background)
}

private struct SettingsPlaceholderRow: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(XPendoTheme.accentTeal.opacity(0.12))
                .frame(width: 42, height: 42)
                .overlay {
                    Image(systemName: systemImage)
                        .foregroundStyle(XPendoTheme.accentTeal)
                }

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(XPendoTheme.primaryText)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(XPendoTheme.secondaryText)
        }
        .padding(14)
        .background(XPendoTheme.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
