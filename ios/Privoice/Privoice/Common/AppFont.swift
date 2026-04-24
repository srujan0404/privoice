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
    static func heavy(_ size: CGFloat) -> Font { .system(size: size, weight: .heavy, design: .rounded) }
}

/// Section header used above grouped cards (e.g. "Today", "Yesterday", "Your Words (6)").
/// CSS spec: SF Pro Rounded, weight 800, 16pt, line-height 20pt, color #8E8E93, 10/8 padding.
struct SectionTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(AppFont.heavy(16))
            .foregroundStyle(Color(red: 0x8E / 255.0, green: 0x8E / 255.0, blue: 0x93 / 255.0))
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
    }
}
