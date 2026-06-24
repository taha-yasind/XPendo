/*
 DOSYA: PlaceholderShapes.swift
 AMAÇ: Empty veya loading state için lightweight decorative placeholder shape viewleri sağlar. Basit reusable shape viewleri merkezileştirir.
 KULLANAN: PlaceholderCard ve placeholder visual gerektiren feature ekranları tarafından kullanılır.
*/
import SwiftUI

// App tarafından kullanılan lightweight value type tanımlar.
struct SkeletonLine: View {
    var width: CGFloat? = nil
    var height: CGFloat = 12

    // Bu view için görünen SwiftUI layout’unu kurar.
    var body: some View {
        RoundedRectangle(cornerRadius: height / 2, style: .continuous)
            .fill(XPendoTheme.placeholder)
            .frame(width: width, height: height)
    }
}

// App tarafından kullanılan lightweight value type tanımlar.
struct PlaceholderProgressBar: View {
    var tint: Color = XPendoTheme.accentTeal
    var progress: CGFloat = 0.6

    // Bu view için görünen SwiftUI layout’unu kurar.
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
