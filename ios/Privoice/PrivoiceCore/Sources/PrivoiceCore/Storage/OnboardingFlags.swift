import Foundation

/// Cross-process flags that the onboarding UI uses to influence keyboard
/// extension behavior. Backed by App Group UserDefaults so the keyboard
/// extension (a separate process) can read them.
public enum OnboardingFlags {
    private static let suppressHistoryKey = "privoice.onboarding.suppressHistory"

    /// True while the user is inside the onboarding flow. The keyboard
    /// extension consults this before persisting polished messages so demo
    /// utterances (e.g. the "Italian place on 5th street" prompt in
    /// `TryVoiceView`) don't pollute the user's real History tab.
    public static var suppressHistory: Bool {
        get { AppGroup.userDefaults.bool(forKey: suppressHistoryKey) }
        set { AppGroup.userDefaults.set(newValue, forKey: suppressHistoryKey) }
    }
}
