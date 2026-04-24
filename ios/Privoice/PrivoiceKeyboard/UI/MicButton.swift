import SwiftUI

struct MicButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "mic.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Color.black, in: .circle)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Start voice input")
    }
}

#Preview {
    MicButton(action: {})
        .padding()
        .background(Color(.systemGray6))
}
