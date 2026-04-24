import SwiftUI
import PrivoiceCore

struct NoteDetailView: View {
    let note: Note
    let onSave: (Note) -> Void
    let onDelete: (Note) -> Void

    @Environment(\.dismiss) private var dismiss
    @FocusState private var bodyFocused: Bool

    @State private var titleText: String
    @State private var bodyText: String
    @State private var hasLoaded = false

    init(
        note: Note,
        onSave: @escaping (Note) -> Void,
        onDelete: @escaping (Note) -> Void
    ) {
        self.note = note
        self.onSave = onSave
        self.onDelete = onDelete
        _titleText = State(initialValue: note.title)
        _bodyText = State(initialValue: note.body)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            editor
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if !hasLoaded {
                hasLoaded = true
                if titleText.isEmpty && bodyText.isEmpty {
                    bodyFocused = true
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 0) {
            Button(action: { saveAndDismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 40, height: 40)
                    .background(Color(.systemBackground), in: .circle)
                    .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
            }
            .buttonStyle(.plain)

            Spacer()

            TextField("Title", text: $titleText)
                .font(.system(size: 17, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)

            Spacer()

            Button(action: { saveAndDismiss() }) {
                Image(systemName: "checkmark")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.accentColor, in: .circle)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var editor: some View {
        TextEditor(text: $bodyText)
            .font(.system(size: 17))
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .padding(.horizontal, 12)
            .padding(.top, 4)
            .focused($bodyFocused)
    }

    private func saveAndDismiss() {
        let trimmedTitle = titleText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBody = bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle.isEmpty && trimmedBody.isEmpty {
            onDelete(note)
        } else {
            var updated = note
            updated.title = trimmedTitle
            updated.body = bodyText
            onSave(updated)
        }
        dismiss()
    }
}
