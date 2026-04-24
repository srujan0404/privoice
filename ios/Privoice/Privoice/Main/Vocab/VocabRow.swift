import SwiftUI
import PrivoiceCore

struct VocabRow: View {
    let entry: VocabEntry

    var body: some View {
        HStack(spacing: 10) {
            if let phonetic = entry.phonetic, !phonetic.isEmpty {
                UnderlinedWord(text: entry.word, font: AppFont.regular(17))
                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(.systemGray3))
                Text(phonetic)
                    .font(AppFont.regular(17))
                    .foregroundStyle(.primary)
            } else {
                Text(entry.word)
                    .font(AppFont.regular(17))
                    .foregroundStyle(.primary)
            }
            Spacer(minLength: 4)
        }
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }
}
