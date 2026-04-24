import SwiftUI
import PrivoiceCore

struct SnippetRow: View {
    let snippet: Snippet

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center) {
                    triggerPill
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(.systemGray3))
                }
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "arrow.turn.down.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(.systemGray3))
                        .padding(.top, 4)
                    Text(snippet.expansion)
                        .font(AppFont.regular(16))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }

    private var triggerPill: some View {
        Text("\u{201C}\(snippet.trigger)\u{201D}")
            .font(AppFont.semibold(15))
            .foregroundStyle(Color.accentColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.accentColor.opacity(0.12), in: .capsule)
    }
}
