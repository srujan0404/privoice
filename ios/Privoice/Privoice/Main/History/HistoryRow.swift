import SwiftUI
import PrivoiceCore

struct HistoryRow: View {
    let message: Message

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(message.polishedText)
                .font(AppFont.regular(16))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text(message.tone.displayName)
                    .font(AppFont.medium(12))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(Self.timeFormatter.string(from: message.createdAt))
                    .font(AppFont.regular(12))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 14)
    }
}
