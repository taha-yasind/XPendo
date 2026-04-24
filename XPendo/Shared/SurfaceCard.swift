import SwiftUI

struct SurfaceCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(XPendoTheme.surfaceBackground, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(XPendoTheme.cardBorder, lineWidth: 1)
            }
            .shadow(color: XPendoTheme.cardShadow, radius: 22, x: 0, y: 12)
    }
}
