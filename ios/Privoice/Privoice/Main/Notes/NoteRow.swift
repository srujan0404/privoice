import SwiftUI
import PrivoiceCore

struct NoteRow: View {
    let note: Note

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            NoteThumbnail(size: 56)
            VStack(alignment: .leading, spacing: 4) {
                Text(note.displayTitle)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                if !note.preview.isEmpty {
                    Text(note.preview)
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Text(Self.timeFormatter.string(from: note.updatedAt))
                    .font(.system(size: 13))
                    .foregroundStyle(Color(.systemGray))
                    .padding(.top, 2)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(.systemGray3))
                .padding(.top, 4)
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
