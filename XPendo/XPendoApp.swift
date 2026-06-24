/*
 DOSYA: XPendoApp.swift
 AMAÇ: SwiftUI app entry point’i tanımlar ve shared SwiftData model container’ı bağlar. iOS tarafından çalıştırılan ilk app-owned Swift dosyasıdır.
 KULLANAN: iOS runtime, AppRootView ve XPendoModelContainer tarafından kullanılır.
*/
import SwiftUI
import SwiftData

// XPendoApp, uygulamanın launch noktasıdır.
// Seçilen AppDataMode'a göre SwiftData ModelContainer'ı hazırlar ve AppRootView'a bağlar.
@main
// App tarafından kullanılan lightweight value type tanımlar.
struct XPendoApp: App {
    @AppStorage(AppModeStore.key) private var isDemoModeEnabled = AppModeStore.isDemoModeEnabled

    // Bu view için görünen SwiftUI layout’unu kurar.
    var body: some Scene {
        let activeMode: AppDataMode = isDemoModeEnabled ? .demo : .standard

        WindowGroup {
            AppRootView()
        }
        // ModelContainer burada environment'a eklenir; alt ekranlar ModelContext'e @Environment ile ulaşır.
        .modelContainer(XPendoModelContainer.container(for: activeMode))
    }
}
