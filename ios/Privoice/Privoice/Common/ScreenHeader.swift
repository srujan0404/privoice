import SwiftUI

/// Inline large-title + avatar header used at the top of every tab.
/// Title CSS from Figma: SF Pro Rounded, Heavy (800), 26pt, line-height 32,
/// letter-spacing -1%, color colors/neutral/900 (#0A0A0A).
struct ScreenHeader: View {
    let title: String

    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(AppFont.heavy(26))
                .tracking(-0.26)   // -1% of 26pt
                .lineSpacing(0)
                .foregroundStyle(Color(red: 0x0A / 255.0, green: 0x0A / 255.0, blue: 0x0A / 255.0))
            Spacer()
            AvatarMenu(size: 36)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}
