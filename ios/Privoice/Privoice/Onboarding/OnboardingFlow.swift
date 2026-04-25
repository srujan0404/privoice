import SwiftUI

/// Container that drives the post-auth onboarding flow (steps 2–7 of the
/// brief — step 1 is `WelcomeView` shown to unauthenticated users). Each
/// step view receives an `onNext` closure that advances the state. Step 7
/// finishes by flipping `appState.hasCompletedOnboarding`, which causes
/// `RootView` to swap in `MainTabView`.
struct OnboardingFlow: View {
    @Environment(AppState.self) private var appState
    @State private var step: Step = .keyboardSetup

    enum Step: Int, CaseIterable {
        case keyboardSetup   // step 2 — "Let's Unlock your Voice"
        case micPermission   // step 3 — "Now let's give it ears."
        case allSet          // step 4 — "Let's Go!"
        case activateVoice   // step 5 — "Activate your Voice"
        case tryVoice        // steps 6 + 7 — "Try your Voice" (with internal listening state)
    }

    var body: some View {
        Group {
            switch step {
            case .keyboardSetup:
                KeyboardSetupView(onNext: advance)
            case .micPermission:
                MicPermissionView(onNext: advance)
            case .allSet:
                AllSetView(onNext: advance)
            case .activateVoice:
                ActivateVoiceView(onNext: advance)
            case .tryVoice:
                TryVoiceView(onNext: complete)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: step)
        .transition(.opacity)
    }

    private func advance() {
        if let next = Step(rawValue: step.rawValue + 1) {
            step = next
        }
    }

    private func complete() {
        appState.hasCompletedOnboarding = true
    }
}
