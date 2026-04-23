import SwiftUI

struct SnippetsPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "scissors")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Snippets")
                .font(.title2).bold()
            Text("Your text expansion snippets will appear here.\nComing in Sub-project 3.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
