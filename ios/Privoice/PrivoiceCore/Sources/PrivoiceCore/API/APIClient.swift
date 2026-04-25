import Foundation

/// Coordinates a single in-flight token refresh so concurrent 401s don't stampede.
actor RefreshCoordinator {
    private var currentTask: Task<Bool, Never>?

    func refreshIfNeeded(_ perform: @Sendable @escaping () async -> Bool) async -> Bool {
        if let existing = currentTask {
            return await existing.value
        }
        let task = Task { await perform() }
        currentTask = task
        let result = await task.value
        currentTask = nil
        return result
    }
}

/// Thin wrapper over URLSession. Call the static methods via `AuthAPI`-style modules;
/// don't import this directly from view code.
public final class APIClient: @unchecked Sendable {
    public static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let tokenStore: TokenStore
    private let refreshCoordinator = RefreshCoordinator()

    public init(
        session: URLSession = .shared,
        tokenStore: TokenStore = .shared
    ) {
        self.session = session
        self.tokenStore = tokenStore

        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            if let date = APIClient.iso8601WithMillis.date(from: raw) { return date }
            if let date = APIClient.iso8601Plain.date(from: raw) { return date }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO-8601 date: \(raw)")
        }
        self.decoder = dec

        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(APIClient.iso8601WithMillis.string(from: date))
        }
        self.encoder = enc
    }

    private static let iso8601WithMillis: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let iso8601Plain: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    /// Public request — authenticated endpoint. Handles 401 refresh + retry once.
    public func authed<Response: Decodable>(
        _ method: String,
        _ path: String,
        queryItems: [URLQueryItem]? = nil,
        body: Encodable? = nil,
        response: Response.Type
    ) async throws -> Response {
        let request = try buildRequest(method: method, path: path, queryItems: queryItems, body: body, authed: true)
        return try await send(request, response: Response.self, allowRefresh: true)
    }

    /// Public request — unauthenticated endpoint (auth endpoints, health, etc.).
    public func unauthed<Response: Decodable>(
        _ method: String,
        _ path: String,
        queryItems: [URLQueryItem]? = nil,
        body: Encodable? = nil,
        response: Response.Type
    ) async throws -> Response {
        let request = try buildRequest(method: method, path: path, queryItems: queryItems, body: body, authed: false)
        return try await send(request, response: Response.self, allowRefresh: false)
    }

    /// Unauthed + no response body (used for endpoints that return `{ok:true}`).
    @discardableResult
    public func unauthedEmpty(
        _ method: String,
        _ path: String,
        queryItems: [URLQueryItem]? = nil,
        body: Encodable? = nil
    ) async throws -> Void {
        struct Empty: Decodable {}
        let request = try buildRequest(method: method, path: path, queryItems: queryItems, body: body, authed: false)
        _ = try await send(request, response: Empty.self, allowRefresh: false)
    }

    // MARK: - Internals

    private func buildRequest(method: String, path: String, queryItems: [URLQueryItem]?, body: Encodable?, authed: Bool) throws -> URLRequest {
        let pathURL = Config.baseURL.appendingPathComponent(path)
        let url: URL
        if let queryItems, !queryItems.isEmpty {
            guard var components = URLComponents(url: pathURL, resolvingAgainstBaseURL: false) else {
                throw APIError.network("Invalid URL for path: \(path)")
            }
            components.queryItems = queryItems
            guard let built = components.url else {
                throw APIError.network("Invalid URL for path: \(path)")
            }
            url = built
        } else {
            url = pathURL
        }
        var req = URLRequest(url: url, timeoutInterval: Config.requestTimeout)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body {
            req.httpBody = try encoder.encode(AnyEncodable(body))
        }
        if authed {
            if let token = tokenStore.load()?.access {
                req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                throw APIError.tokenInvalid
            }
        }
        return req
    }

    private func send<Response: Decodable>(
        _ request: URLRequest,
        response: Response.Type,
        allowRefresh: Bool
    ) async throws -> Response {
        let (data, urlResponse): (Data, URLResponse)
        do {
            (data, urlResponse) = try await session.data(for: request)
        } catch {
            throw APIError.network(error.localizedDescription)
        }

        guard let http = urlResponse as? HTTPURLResponse else {
            throw APIError.network("Non-HTTP response")
        }

        if (200..<300).contains(http.statusCode) {
            if Response.self == EmptyResponse.self || data.isEmpty {
                // Safe because we only hit this when Response permits it.
                return try decoder.decode(Response.self, from: data.isEmpty ? Data("{}".utf8) : data)
            }
            return try decoder.decode(Response.self, from: data)
        }

        // Non-2xx. Map to APIError.
        let serverError = decodeServerError(data: data, status: http.statusCode)

        // 401 AUTH_TOKEN_INVALID — refresh and retry once.
        if http.statusCode == 401,
           case .tokenInvalid = serverError,
           allowRefresh
        {
            let refreshed = await refreshCoordinator.refreshIfNeeded { [self] in
                await performRefresh()
            }
            if refreshed {
                // Rebuild the request with new access token and resend (no further refresh).
                var retry = request
                if let newAccess = tokenStore.load()?.access {
                    retry.setValue("Bearer \(newAccess)", forHTTPHeaderField: "Authorization")
                }
                return try await send(retry, response: Response.self, allowRefresh: false)
            } else {
                tokenStore.clear()
                throw APIError.tokenInvalid
            }
        }

        throw serverError
    }

    private func performRefresh() async -> Bool {
        guard let current = tokenStore.load() else { return false }
        struct Body: Encodable { let refreshToken: String }
        do {
            let body = Body(refreshToken: current.refresh)
            let url = Config.baseURL.appendingPathComponent("auth/refresh")
            var req = URLRequest(url: url, timeoutInterval: Config.requestTimeout)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try encoder.encode(body)

            let (data, urlResponse) = try await session.data(for: req)
            guard let http = urlResponse as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                return false
            }
            struct RefreshResponse: Decodable {
                let accessToken: String
                let refreshToken: String
            }
            let decoded = try decoder.decode(RefreshResponse.self, from: data)
            try tokenStore.save(.init(access: decoded.accessToken, refresh: decoded.refreshToken))
            return true
        } catch {
            return false
        }
    }

    private func decodeServerError(data: Data, status: Int) -> APIError {
        struct Envelope: Decodable {
            struct Err: Decodable {
                let code: String
                let message: String
                let details: [DetailItem]?
            }
            let error: Err
        }
        struct DetailItem: Decodable { let path: String; let message: String }

        guard let envelope = try? decoder.decode(Envelope.self, from: data) else {
            return .server(code: "UNKNOWN", message: "Server returned status \(status)", status: status)
        }

        switch envelope.error.code {
        case "VALIDATION_FAILED":
            let fields = Dictionary(uniqueKeysWithValues: (envelope.error.details ?? []).map { ($0.path, $0.message) })
            return .validationFailed(fields: fields)
        case "AUTH_INVALID_CREDENTIALS":
            return .invalidCredentials
        case "AUTH_EMAIL_TAKEN":
            return .emailTaken
        case "AUTH_TOKEN_INVALID":
            return .tokenInvalid
        case "RATE_LIMITED":
            return .rateLimited
        default:
            return .server(code: envelope.error.code, message: envelope.error.message, status: status)
        }
    }
}

struct EmptyResponse: Decodable {}

/// Erases the concrete Encodable type at the call site.
struct AnyEncodable: Encodable {
    let value: Encodable
    init(_ value: Encodable) { self.value = value }
    func encode(to encoder: Encoder) throws { try value.encode(to: encoder) }
}
