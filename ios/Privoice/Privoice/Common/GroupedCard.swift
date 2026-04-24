import SwiftUI

extension Color {
    /// #F9F9FB — the card background color used across all list screens.
    static let cardBackground = Color(red: 0xF9 / 255.0, green: 0xF9 / 255.0, blue: 0xFB / 255.0)
}

/// White rounded card container with thin dividers between child rows,
/// matching the Figma pattern used on every list screen.
struct GroupedCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .background(Color.cardBackground, in: .rect(cornerRadius: 16))
    }
}

/// A 1pt divider that mirrors iOS list separators but respects leading inset.
struct CardDivider: View {
    var leading: CGFloat = 18

    var body: some View {
        Rectangle()
            .fill(Color(.separator).opacity(0.4))
            .frame(height: 0.5)
            .padding(.leading, leading)
    }
}
