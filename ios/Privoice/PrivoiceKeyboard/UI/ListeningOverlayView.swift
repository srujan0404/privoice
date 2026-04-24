import SwiftUI

struct ListeningOverlayView: View {
    @ObservedObject var buffer: TranscriptBuffer
    @ObservedObject var level: AudioLevelProvider

    let onCancel: () -> Void
    let onConfirm: () -> Void
    let onDismissToReview: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            transcriptBody
            footer
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 260)
        .background(Color(.systemGray6))
    }

    private var header: some View {
        HStack {
            circleButton(system: "xmark", bg: .white, fg: .black, action: onCancel)
            Spacer()
            WaveformView(level: level.level)
            Spacer()
            circleButton(system: "checkmark", bg: .accentColor, fg: .white, action: onConfirm)
        }
    }

    @ViewBuilder
    private var transcriptBody: some View {
        let text = buffer.full
        ScrollView {
            Text(text.isEmpty ? "Listening..." : text)
                .font(.body)
                .foregroundStyle(text.isEmpty ? .secondary : .primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 16)
                .animation(nil, value: text)
        }
        .frame(maxHeight: .infinity)
    }

    private var footer: some View {
        HStack {
            Spacer()
            Button(action: onDismissToReview) {
                Image(systemName: "keyboard.chevron.compact.down")
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .frame(height: 36)
    }

    private func circleButton(system: String, bg: Color, fg: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(fg)
                .frame(width: 36, height: 36)
                .background(bg, in: .circle)
        }
        .buttonStyle(.plain)
    }
}
