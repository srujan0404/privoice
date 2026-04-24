import SwiftUI
import PrivoiceCore

struct ToneCardView: View {
    let tone: Tone
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    Text(tone.displayName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(isSelected ? Color.accentColor : .primary)
                    Spacer(minLength: 8)
                    selectionIndicator
                }
                Text(tone.tagline)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 12)
                exampleBubble
            }
            .padding(16)
            .frame(width: 240, height: 210, alignment: .topLeading)
            .background(Color(.systemBackground), in: .rect(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? Color.accentColor : Color(.systemGray5), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var selectionIndicator: some View {
        Group {
            if isSelected {
                ZStack {
                    Circle().fill(Color(red: 0.20, green: 0.78, blue: 0.35))
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 22, height: 22)
            } else {
                Circle()
                    .stroke(Color(.systemGray4), lineWidth: 1.5)
                    .frame(width: 22, height: 22)
            }
        }
    }

    private var exampleBubble: some View {
        Text(tone.exampleText)
            .font(.system(size: 13))
            .foregroundStyle(.primary)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.systemGray6), in: .rect(cornerRadius: 14))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
