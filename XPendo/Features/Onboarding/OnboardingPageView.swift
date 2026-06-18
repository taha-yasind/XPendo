import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 26) {
            Spacer(minLength: 24)

            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(XPendoTheme.accentTeal.opacity(0.12))
                .frame(width: 132, height: 132)
                .overlay {
                    Image(systemName: page.systemImage)
                        .font(.system(size: 58, weight: .semibold))
                        .foregroundStyle(XPendoTheme.accentTeal)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .strokeBorder(XPendoTheme.accentTeal.opacity(0.16), lineWidth: 1)
                }

            VStack(spacing: 12) {
                Text(AppLocalization.string(page.titleKey))
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(XPendoTheme.primaryText)
                    .multilineTextAlignment(.center)

                Text(AppLocalization.string(page.descriptionKey))
                    .font(.body)
                    .foregroundStyle(XPendoTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 14)
            }

            Spacer(minLength: 24)
        }
        .padding(.horizontal, 24)
    }
}
