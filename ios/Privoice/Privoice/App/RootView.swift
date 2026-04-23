import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        switch appState.authStatus {
        case .checking:
            ProgressView()
                .controlSize(.large)
        case .unauthenticated:
            LoginView()
        case .authenticated:
            MainTabView()
        }
    }
}
