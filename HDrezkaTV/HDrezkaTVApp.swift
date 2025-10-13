import Combine
import Defaults
import SwiftData
import SwiftUI

// tvOS-адаптована версія AppDelegate
class TVAppDelegate: NSObject, UIApplicationDelegate {
    func applicationDidFinishLaunching(_ application: UIApplication) {
        // Firebase та аналітика можуть бути додані пізніше
        // FirebaseApp.configure()
    }
}

@main
struct HDrezkaTVApp: App {
    @UIApplicationDelegateAdaptor(TVAppDelegate.self) private var delegate
    @State private var appState: AppState = .shared
    
    @State private var modelContainer: ModelContainer
    
    @Default(.theme) private var theme
    
    init() {
        do {
            let schema = Schema([PlayerPosition.self, SelectPosition.self])
            let modelContainer = try ModelContainer(for: schema)
            modelContainer.mainContext.autosaveEnabled = true
            self.modelContainer = modelContainer
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            TVContentView()
                .environment(appState)
                .preferredColorScheme(theme.scheme)
        }
        .modelContainer(modelContainer)
    }
}

