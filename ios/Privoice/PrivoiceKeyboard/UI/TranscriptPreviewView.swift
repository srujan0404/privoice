import SwiftUI

struct TranscriptPreviewView: View {
    @ObservedObject var buffer: TranscriptBuffer
    let reviewEditor: ReviewEditorProxy

    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            header
            textArea
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .padding(.bottom, 6)
    }

    private var header: some View {
        HStack {
            circleButton(system: "xmark", bg: .white, fg: .black, action: onCancel)
            Spacer()
            circleButton(system: "checkmark", bg: .accentColor, fg: .white, action: onConfirm)
        }
        .padding(.horizontal, 4)
    }

    private var textArea: some View {
        TranscriptEditor(buffer: buffer, proxy: reviewEditor)
            .frame(minHeight: 110, maxHeight: 180)
            .background(Color(.systemBackground), in: .rect(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 0.5))
    }

    private func circleButton(system: String, bg: Color, fg: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(fg)
                .frame(width: 40, height: 40)
                .background(bg, in: .circle)
        }
        .buttonStyle(.plain)
    }
}
