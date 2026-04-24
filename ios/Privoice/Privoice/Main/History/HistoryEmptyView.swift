import SwiftUI

struct HistoryEmptyView: View {
    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 56, weight: .medium))
                .foregroundStyle(Color.accentColor)
            Text("There's nothing here, yet")
                .font(.system(size: 20, weight: .semibold))
            Text("Your pocket voice history will appear here once you start sending messages.")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
