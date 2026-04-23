import Foundation

public struct AuthResponse: Codable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let user: User
}
