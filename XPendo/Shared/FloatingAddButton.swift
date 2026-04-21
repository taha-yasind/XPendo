import SwiftUI

struct FloatingAddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [XPendoTheme.accentTeal, XPendoTheme.freshGreen],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 68, height: 68)

                    Image(systemName: "plus")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                }
                .shadow(color: XPendoTheme.accentTeal.opacity(0.32), radius: 18, x: 0, y: 10)

                Text("Add")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(XPendoTheme.primaryText)
            }
            .padding(.horizontal, 14)
            .padding(.top, 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add Expense")
    }
}
