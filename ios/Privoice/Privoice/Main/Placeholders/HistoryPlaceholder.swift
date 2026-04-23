import SwiftUI

struct HistoryPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "paperplane")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("History")
                .font(.title2).bold()
            Text("Your dictated messages will appear here.\nComing in Sub-project 3.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
