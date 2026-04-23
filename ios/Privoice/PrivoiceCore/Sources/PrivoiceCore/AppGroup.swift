import Foundation

public enum AppGroup {
    /// App Group suite identifier shared between the main app and the keyboard extension.
    public static let identifier = "group.com.privoice"

    /// UserDefaults scoped to the shared App Group (non-secret settings).
    public static var userDefaults: UserDefaults {
        guard let d = UserDefaults(suiteName: identifier) else {
            fatalError("App Group \(identifier) is not configured — check entitlements")
        }
        return d
    }

    /// Filesystem container shared between app and keyboard. GRDB DB file lives here.
    public static var containerURL: URL {
        guard let url = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: identifier
        ) else {
            fatalError("App Group container for \(identifier) is unavailable — check entitlements")
        }
        return url
    }

    /// Path to the shared SQLite database file.
    public static var databaseURL: URL {
        containerURL.appendingPathComponent("privoice.sqlite")
    }

    /// Keychain access group used for token storage. Matches the entitlement value.
    public static let keychainAccessGroup = "com.privoice.shared"
}
