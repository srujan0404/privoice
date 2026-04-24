import Foundation

public struct PolishResponse: Codable, Sendable, Equatable {
    public let polishedText: String
    public let provider: String
    public let latencyMs: Int

    public init(polishedText: String, provider: String, latencyMs: Int) {
        self.polishedText = polishedText
        self.provider = provider
        self.latencyMs = latencyMs
    }
}
