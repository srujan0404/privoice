import Foundation

/// High-level polish endpoint wrapper. Authenticated: requires a valid access token.
public enum PolishAPI {
    public struct Body: Encodable {
        public let transcript: String
        public let tone: String
        public let appName: String?
    }

    /// Calls POST /polish. Throws APIError on failure (network, auth, validation, or server).
    public static func polish(
        transcript: String,
        tone: Tone = .default,
        appName: String? = nil
    ) async throws -> PolishResponse {
        let body = Body(transcript: transcript, tone: tone.rawValue, appName: appName)
        return try await APIClient.shared.authed(
            "POST", "polish",
            body: body,
            response: PolishResponse.self
        )
    }
}
