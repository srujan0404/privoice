import Foundation
import Observation
import PrivoiceCore
import GoogleSignIn

private let onboardingDoneKey = "privoice.hasCompletedOnboarding"
private let lastUserIdKey = "privoice.lastUserId"
private let userScopedWipeMigrationKey = "privoice.userScopedDataWipe.v1"

@Observable
@MainActor
public final class AppState {
    public enum AuthStatus: Equatable {
        case checking
        case unauthenticated
        case authenticated(User)
    }

    public var authStatus: AuthStatus = .checking

    public var hasCompletedOnboarding: Bool = UserDefaults.standard.bool(forKey: onboardingDoneKey) {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: onboardingDoneKey)
        }
    }

    public init() {
        runOneTimeWipeMigrationIfNeeded()
        // Defensive: clear if the previous session crashed mid-onboarding and
        // left the flag stuck on, which would silently break history writes.
        OnboardingFlags.suppressHistory = false
    }

    public func bootstrap() async {
        guard TokenStore.shared.load() != nil else {
            authStatus = .unauthenticated
            return
        }

        do {
            let user = try await AuthAPI.me()
            applyUserSwitchIfNeeded(newUserId: user.id)
            authStatus = .authenticated(user)
        } catch APIError.tokenInvalid {
            TokenStore.shared.clear()
            authStatus = .unauthenticated
        } catch {
            authStatus = .unauthenticated
        }
    }

    public func signIn(with response: AuthResponse) {
        applyUserSwitchIfNeeded(newUserId: response.user.id)
        try? TokenStore.shared.save(.init(access: response.accessToken, refresh: response.refreshToken))
        authStatus = .authenticated(response.user)
    }

    public func signOut() async {
        if let refresh = TokenStore.shared.load()?.refresh {
            await AuthAPI.logout(refreshToken: refresh)
        }
        TokenStore.shared.clear()
        GIDSignIn.sharedInstance.signOut()
        wipeLocalUserData()
        authStatus = .unauthenticated
    }

    /// One-time migration: previous builds didn't track which user owned the
    /// local cache, so dharma's data leaked into srujan's session. Wipe once on
    /// first launch with this build, then mark done so we don't keep doing it.
    private func runOneTimeWipeMigrationIfNeeded() {
        guard !AppGroup.userDefaults.bool(forKey: userScopedWipeMigrationKey) else { return }
        wipeLocalUserData()
        AppGroup.userDefaults.set(true, forKey: userScopedWipeMigrationKey)
    }

    private func applyUserSwitchIfNeeded(newUserId: String) {
        let previousUserId = AppGroup.userDefaults.string(forKey: lastUserIdKey)
        if let previousUserId, previousUserId != newUserId {
            wipeLocalUserData()
        }
        AppGroup.userDefaults.set(newUserId, forKey: lastUserIdKey)
    }

    private func wipeLocalUserData() {
        try? DatabaseManager.shared.wipeAllData()
        UserDefaults.standard.removePersistentDomain(forName: AppGroup.identifier)
        UserDefaults.standard.removeObject(forKey: onboardingDoneKey)
        hasCompletedOnboarding = false
    }
}
