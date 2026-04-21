import SwiftUI

struct SkeletonLine: View {
    var width: CGFloat? = nil
    var height: CGFloat = 12

    var body: some View {
        RoundedRectangle(cornerRadius: height / 2, style: .continuous)
            .fill(XPendoTheme.placeholder)
            .frame(width: width, height: height)
    }
}

struct PlaceholderProgressBar: View {
    var tint: Color = XPendoTheme.accentTeal
    var progress: CGFloat = 0.6

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(XPendoTheme.placeholder.opacity(0.8))

                Capsule()
                    .fill(tint.opacity(0.75))
                    .frame(width: max(geometry.size.width * progress, 24))
            }
        }
        .frame(height: 10)
    }
}
