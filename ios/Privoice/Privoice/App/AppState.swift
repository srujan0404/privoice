import Foundation
import Observation
import PrivoiceCore

@Observable
@MainActor
public final class AppState {
    public enum AuthStatus: Equatable {
        case checking
        case unauthenticated
        case authenticated(User)
    }

    public var authStatus: AuthStatus = .checking

    public init() {}

    /// Called from `.task` on the root view. Loads stored tokens and validates them.
    public func bootstrap() async {
        guard let tokens = TokenStore.shared.load() else {
            authStatus = .unauthenticated
            return
        }

        do {
            let user = try await AuthAPI.me()
            authStatus = .authenticated(user)
        } catch APIError.tokenInvalid {
            TokenStore.shared.clear()
            authStatus = .unauthenticated
        } catch {
            authStatus = .unauthenticated
        }
        _ = tokens
    }

    public func signIn(with response: AuthResponse) {
        try? TokenStore.shared.save(.init(access: response.accessToken, refresh: response.refreshToken))
        authStatus = .authenticated(response.user)
    }

    public func signOut() async {
        if let refresh = TokenStore.shared.load()?.refresh {
            await AuthAPI.logout(refreshToken: refresh)
        }
        TokenStore.shared.clear()
        authStatus = .unauthenticated
    }
}
