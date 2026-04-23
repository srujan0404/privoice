import SwiftUI

struct VocabPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "character.book.closed")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Vocab")
                .font(.title2).bold()
            Text("Custom words that help the speech recognizer.\nComing in Sub-project 3.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
