import SwiftUI
import GoogleSignIn

@main
struct PrivoiceApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .task { await appState.bootstrap() }
                .onOpenURL { GIDSignIn.sharedInstance.handle($0) }
        }
    }
}
