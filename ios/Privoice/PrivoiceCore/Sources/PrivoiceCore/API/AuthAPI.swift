import Foundation

/// High-level auth endpoints. All wrap APIClient with typed inputs/outputs.
public enum AuthAPI {
    public struct RegisterBody: Encodable {
        public let email: String
        public let password: String
        public let displayName: String
    }
    public struct LoginBody: Encodable {
        public let email: String
        public let password: String
    }
    public struct RefreshBody: Encodable { public let refreshToken: String }
    public struct LogoutBody: Encodable { public let refreshToken: String }

    public static func register(email: String, password: String, displayName: String) async throws -> AuthResponse {
        try await APIClient.shared.unauthed(
            "POST", "auth/register",
            body: RegisterBody(email: email, password: password, displayName: displayName),
            response: AuthResponse.self
        )
    }

    public static func login(email: String, password: String) async throws -> AuthResponse {
        try await APIClient.shared.unauthed(
            "POST", "auth/login",
            body: LoginBody(email: email, password: password),
            response: AuthResponse.self
        )
    }

    public static func logout(refreshToken: String) async {
        // Fire-and-forget: logout errors shouldn't block sign-out UX.
        _ = try? await APIClient.shared.unauthedEmpty(
            "POST", "auth/logout",
            body: LogoutBody(refreshToken: refreshToken)
        )
    }

    public static func me() async throws -> User {
        try await APIClient.shared.authed("GET", "me", response: User.self)
    }
}
