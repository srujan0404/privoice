import SwiftUI

/// Inline large-title + avatar header used at the top of every tab,
/// matching the Figma layout where the title and avatar sit on the same row.
struct ScreenHeader: View {
    let title: String

    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(AppFont.bold(32))
                .foregroundStyle(.primary)
            Spacer()
            AvatarMenu(size: 36)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}
