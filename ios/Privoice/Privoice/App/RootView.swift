import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        switch appState.authStatus {
        case .checking:
            ProgressView()
                .controlSize(.large)
        case .unauthenticated:
            WelcomeView()
        case .authenticated:
            if appState.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingFlow()
            }
        }
    }
}
