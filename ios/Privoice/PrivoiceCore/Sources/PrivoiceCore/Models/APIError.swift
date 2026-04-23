import Foundation

public enum APIError: Error, Sendable, Equatable {
    /// 400 VALIDATION_FAILED — fields maps JSON path to human-readable message.
    case validationFailed(fields: [String: String])

    /// 401 AUTH_INVALID_CREDENTIALS
    case invalidCredentials

    /// 409 AUTH_EMAIL_TAKEN
    case emailTaken

    /// 401 AUTH_TOKEN_INVALID
    case tokenInvalid

    /// 429 RATE_LIMITED
    case rateLimited

    /// Transport failure, timeout, no network, etc. Not a server-side error.
    case network(String)

    /// Any other server-side error — the envelope code + message + HTTP status.
    case server(code: String, message: String, status: Int)

    /// Human-readable message for surfacing in alerts.
    public var userMessage: String {
        switch self {
        case .validationFailed(let fields):
            if let first = fields.first { return "\(first.key): \(first.value)" }
            return "Please check your input and try again."
        case .invalidCredentials:
            return "Email or password is incorrect."
        case .emailTaken:
            return "This email is already registered. Try signing in."
        case .tokenInvalid:
            return "Your session has expired. Please sign in again."
        case .rateLimited:
            return "Too many requests. Please wait a moment and try again."
        case .network(let msg):
            return "Network error: \(msg)"
        case .server(_, let message, _):
            return message
        }
    }
}
