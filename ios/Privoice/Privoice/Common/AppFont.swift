import SwiftUI

/// Central font factory so we can swap the whole app's typography in one place.
/// Currently uses SF Pro Rounded (a close system stand-in for Open Runde / Inter
/// rounded variants). If the user bundles an actual font file (e.g. OpenRunde,
/// Inter), swap these helpers to `Font.custom(...)` without touching call sites.
enum AppFont {
    static func regular(_ size: CGFloat) -> Font { .system(size: size, weight: .regular, design: .rounded) }
    static func medium(_ size: CGFloat) -> Font { .system(size: size, weight: .medium, design: .rounded) }
    static func semibold(_ size: CGFloat) -> Font { .system(size: size, weight: .semibold, design: .rounded) }
    static func bold(_ size: CGFloat) -> Font { .system(size: size, weight: .bold, design: .rounded) }
}
