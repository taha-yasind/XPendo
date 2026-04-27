import SwiftUI
import SwiftData

@main
struct XPendoApp: App {
    @AppStorage(AppModeStore.key) private var isDemoModeEnabled = AppModeStore.isDemoModeEnabled

    var body: some Scene {
        let activeMode: AppDataMode = isDemoModeEnabled ? .demo : .standard

        WindowGroup {
            AppRootView()
        }
        .modelContainer(XPendoModelContainer.container(for: activeMode))
    }
}
