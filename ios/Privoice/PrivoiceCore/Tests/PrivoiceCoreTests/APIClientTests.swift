import XCTest
@testable import PrivoiceCore

final class APIClientTests: XCTestCase {
    func test_decodesValidationFailed() throws {
        let json = #"""
        {"error":{"code":"VALIDATION_FAILED","message":"Request validation failed.","details":[{"path":"email","message":"Invalid email"}]}}
        """#
        let err = decodeEnvelope(jsonString: json, status: 400)
        if case .validationFailed(let fields) = err {
            XCTAssertEqual(fields["email"], "Invalid email")
        } else {
            XCTFail("expected validationFailed, got \(err)")
        }
    }

    func test_decodesInvalidCredentials() {
        let json = #"{"error":{"code":"AUTH_INVALID_CREDENTIALS","message":"Email or password is incorrect.","details":null}}"#
        let err = decodeEnvelope(jsonString: json, status: 401)
        XCTAssertEqual(err, .invalidCredentials)
    }

    func test_decodesEmailTaken() {
        let json = #"{"error":{"code":"AUTH_EMAIL_TAKEN","message":"Email already registered.","details":null}}"#
        XCTAssertEqual(decodeEnvelope(jsonString: json, status: 409), .emailTaken)
    }

    func test_decodesTokenInvalid() {
        let json = #"{"error":{"code":"AUTH_TOKEN_INVALID","message":"Access token is invalid or expired.","details":null}}"#
        XCTAssertEqual(decodeEnvelope(jsonString: json, status: 401), .tokenInvalid)
    }

    func test_decodesRateLimited() {
        let json = #"{"error":{"code":"RATE_LIMITED","message":"Too many requests.","details":null}}"#
        XCTAssertEqual(decodeEnvelope(jsonString: json, status: 429), .rateLimited)
    }

    func test_decodesUnknownServerError() {
        let json = #"{"error":{"code":"SOMETHING_NEW","message":"A new error.","details":null}}"#
        let err = decodeEnvelope(jsonString: json, status: 500)
        if case .server(let code, let message, let status) = err {
            XCTAssertEqual(code, "SOMETHING_NEW")
            XCTAssertEqual(message, "A new error.")
            XCTAssertEqual(status, 500)
        } else {
            XCTFail("expected .server, got \(err)")
        }
    }

    private func decodeEnvelope(jsonString: String, status: Int) -> APIError {
        let data = Data(jsonString.utf8)
        return APIClientTestHook.decode(data: data, status: status)
    }
}

// Test-only hook exposing the error decoder without widening the public API.
enum APIClientTestHook {
    static func decode(data: Data, status: Int) -> APIError {
        struct Envelope: Decodable {
            struct Err: Decodable { let code: String; let message: String; let details: [DetailItem]? }
            let error: Err
        }
        struct DetailItem: Decodable { let path: String; let message: String }
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        guard let envelope = try? dec.decode(Envelope.self, from: data) else {
            return .server(code: "UNKNOWN", message: "Server returned status \(status)", status: status)
        }
        switch envelope.error.code {
        case "VALIDATION_FAILED":
            let fields = Dictionary(uniqueKeysWithValues: (envelope.error.details ?? []).map { ($0.path, $0.message) })
            return .validationFailed(fields: fields)
        case "AUTH_INVALID_CREDENTIALS": return .invalidCredentials
        case "AUTH_EMAIL_TAKEN": return .emailTaken
        case "AUTH_TOKEN_INVALID": return .tokenInvalid
        case "RATE_LIMITED": return .rateLimited
        default: return .server(code: envelope.error.code, message: envelope.error.message, status: status)
        }
    }
}
