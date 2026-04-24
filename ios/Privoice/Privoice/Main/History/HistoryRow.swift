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
                .font(.system(size: 16))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text(message.tone.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(Self.timeFormatter.string(from: message.createdAt))
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6), in: .rect(cornerRadius: 14))
    }
}
