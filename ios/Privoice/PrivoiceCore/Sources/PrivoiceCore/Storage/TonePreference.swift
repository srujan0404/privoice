import Foundation

/// Reads and writes the user-selected tone in AppGroup-shared UserDefaults.
/// Both the keyboard extension and the main app access this.
public final class TonePreference: @unchecked Sendable {
    public static let shared = TonePreference()

    private let defaults: UserDefaults
    private let key = "selectedTone"

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    /// Test-only initializer that takes a plain UserDefaults (so tests can use a suite name
    /// without the App Group container requirement).
    public init(userDefaults: UserDefaults) {
        self.defaults = userDefaults
    }

    public var current: Tone {
        get {
            guard let raw = defaults.string(forKey: key), let tone = Tone(rawValue: raw) else {
                return .default
            }
            return tone
        }
        set {
            defaults.set(newValue.rawValue, forKey: key)
        }
    }
}
