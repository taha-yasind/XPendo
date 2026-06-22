import SwiftUI
import SwiftData

// XPendoApp, uygulamanın launch noktasıdır.
// Seçilen AppDataMode'a göre SwiftData ModelContainer'ı hazırlar ve AppRootView'a bağlar.
@main
struct XPendoApp: App {
    @AppStorage(AppModeStore.key) private var isDemoModeEnabled = AppModeStore.isDemoModeEnabled

    var body: some Scene {
        let activeMode: AppDataMode = isDemoModeEnabled ? .demo : .standard

        WindowGroup {
            AppRootView()
        }
        // ModelContainer burada environment'a eklenir; alt ekranlar ModelContext'e @Environment ile ulaşır.
        .modelContainer(XPendoModelContainer.container(for: activeMode))
    }
}
