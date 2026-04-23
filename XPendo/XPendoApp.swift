import SwiftUI
import SwiftData

@main
struct XPendoApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(XPendoModelContainer.shared)
    }
}
