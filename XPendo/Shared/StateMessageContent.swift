import SwiftUI

// StateMessageContent, empty/error/info durumlarını ikon, açıklama ve opsiyonel aksiyonla gösteren ortak View'dur.
struct StateMessageContent: View {
    let systemImage: String
    let title: String
    let description: String
    let accentColor: Color
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        systemImage: String,
        title: String,
        description: String,
        accentColor: Color = XPendoTheme.accentTeal,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.systemImage = systemImage
        self.title = title
        self.description = description
        self.accentColor = accentColor
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(accentColor.opacity(0.12))
                .frame(width: 52, height: 52)
                .overlay {
                    Image(systemName: systemImage)
                        .font(.headline)
                        .foregroundStyle(accentColor)
                }

            Text(title)
                .font(.headline)
                .foregroundStyle(XPendoTheme.primaryText)

            Text(description)
                .font(.subheadline)
                .foregroundStyle(XPendoTheme.secondaryText)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.plain)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(accentColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(accentColor.opacity(0.12), in: Capsule())
            }
        }
    }
}
