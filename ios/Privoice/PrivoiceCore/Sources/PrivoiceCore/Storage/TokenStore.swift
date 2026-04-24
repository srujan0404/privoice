import Foundation
import Security

/// Stores access + refresh tokens in the Keychain shared between app and keyboard.
public final class TokenStore: @unchecked Sendable {
    public struct Tokens: Sendable, Equatable {
        public let access: String
        public let refresh: String
        public init(access: String, refresh: String) {
            self.access = access
            self.refresh = refresh
        }
    }

    private let service: String
    private let accessGroup: String?

    public static let shared = TokenStore()

    /// `accessGroup` defaults to nil on purpose. Both the app and keyboard entitlements
    /// declare exactly one `keychain-access-groups` entry (`$(AppIdentifierPrefix)com.privoice.shared`),
    /// so iOS uses it automatically for SecItemAdd and searches all accessible groups for
    /// SecItemCopyMatching. Passing the literal `"com.privoice.shared"` string would
    /// mismatch the team-ID-prefixed runtime value and silently drop writes on simulator.
    public init(service: String = "com.privoice.tokens", accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }

    private let accessKey = "access"
    private let refreshKey = "refresh"

    public func save(_ tokens: Tokens) throws {
        try set(key: accessKey, value: tokens.access)
        try set(key: refreshKey, value: tokens.refresh)
    }

    public func load() -> Tokens? {
        guard
            let access = get(key: accessKey),
            let refresh = get(key: refreshKey)
        else { return nil }
        return Tokens(access: access, refresh: refresh)
    }

    public func updateAccess(_ newAccess: String) throws {
        try set(key: accessKey, value: newAccess)
    }

    public func clear() {
        delete(key: accessKey)
        delete(key: refreshKey)
    }

    // MARK: - Keychain primitives

    private func set(key: String, value: String) throws {
        let data = Data(value.utf8)
        var query = baseQuery(key: key)

        // Try update first; if nothing to update, insert.
        let updateAttrs: [String: Any] = [kSecValueData as String: data]
        let updateStatus = SecItemUpdate(query as CFDictionary, updateAttrs as CFDictionary)
        if updateStatus == errSecSuccess { return }
        if updateStatus != errSecItemNotFound {
            throw KeychainError.unexpected(updateStatus)
        }

        var insert = query
        insert[kSecValueData as String] = data
        insert[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        let addStatus = SecItemAdd(insert as CFDictionary, nil)
        guard addStatus == errSecSuccess else { throw KeychainError.unexpected(addStatus) }
    }

    private func get(key: String) -> String? {
        var query = baseQuery(key: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data, let str = String(data: data, encoding: .utf8) else {
            return nil
        }
        return str
    }

    private func delete(key: String) {
        let query = baseQuery(key: key)
        _ = SecItemDelete(query as CFDictionary)
    }

    private func baseQuery(key: String) -> [String: Any] {
        var q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
        if let group = accessGroup {
            q[kSecAttrAccessGroup as String] = group
        }
        return q
    }

    enum KeychainError: Error, Equatable {
        case unexpected(OSStatus)
    }
}
