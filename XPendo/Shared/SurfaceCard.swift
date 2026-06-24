/*
 DOSYA: SurfaceCard.swift
 AMAÇ: App’in reusable card container styling yapısını tanımlar. Panel ve grouped content görünümlerini tutarlı tutar.
 KULLANAN: HomeView, BudgetView, ExpensesView, AnalyticsView, SettingsView ve shared componentler tarafından kullanılır.
*/
import SwiftUI

// SurfaceCard, XPendo ekranlarında tekrar kullanılan kart yüzeyi ve spacing standardını sağlar.
// İçerik değişse de background, border ve shadow tutarlı kalır.
struct SurfaceCard<Content: View>: View {
    private let content: Content

    // Bu value’yu çalışmak için ihtiyaç duyduğu data ile hazırlar.
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    // Bu view için görünen SwiftUI layout’unu kurar.
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
