import Foundation

public struct User: Codable, Sendable, Equatable, Hashable {
    public let id: String
    public let email: String
    public let displayName: String
    public let createdAt: Date

    public init(id: String, email: String, displayName: String, createdAt: Date) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.createdAt = createdAt
    }
}
