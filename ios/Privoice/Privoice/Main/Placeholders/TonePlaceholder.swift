import SwiftUI

struct TonePlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "face.smiling")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Tone")
                .font(.title2).bold()
            Text("Pick the tone used for AI polish.\nComing in Sub-project 3.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
