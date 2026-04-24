import SwiftUI
import PrivoiceCore

struct NewVocabView: View {
    let existing: VocabEntry?
    let onSubmit: (_ word: String, _ phonetic: String?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var wordText: String
    @State private var phoneticText: String
    @FocusState private var wordFocused: Bool

    init(
        existing: VocabEntry? = nil,
        onSubmit: @escaping (_ word: String, _ phonetic: String?) -> Void
    ) {
        self.existing = existing
        self.onSubmit = onSubmit
        _wordText = State(initialValue: existing?.word ?? "")
        _phoneticText = State(initialValue: existing?.phonetic ?? "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    section(title: "Word or phrase") {
                        TextField(
                            "",
                            text: $wordText,
                            prompt: Text("Eg. Ajay").foregroundColor(.secondary)
                        )
                        .font(.system(size: 17))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(wordFocused ? Color.accentColor : Color.clear, lineWidth: 1.8)
                        )
                        .focused($wordFocused)
                    }

                    section(title: "Replacement (optional)") {
                        TextField(
                            "",
                            text: $phoneticText,
                            prompt: Text("Eg. btw").foregroundColor(.secondary)
                        )
                        .font(.system(size: 17))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 24)
            }
        }
        .background(Color(.systemBackground))
        .onAppear {
            if existing == nil {
                wordFocused = true
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .background(Color(.systemGray5), in: .circle)
            }
            .buttonStyle(.plain)

            Spacer()

            Text(existing == nil ? "New Word" : "Edit Word")
                .font(.system(size: 17, weight: .semibold))

            Spacer()

            Button(action: submit) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(canSubmit ? Color.accentColor : Color(.systemGray3), in: .circle)
            }
            .buttonStyle(.plain)
            .disabled(!canSubmit)
        }
    }

    private func section<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
            content()
        }
    }

    private var canSubmit: Bool {
        !wordText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func submit() {
        guard canSubmit else { return }
        let trimmedWord = wordText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhonetic = phoneticText.trimmingCharacters(in: .whitespacesAndNewlines)
        onSubmit(trimmedWord, trimmedPhonetic.isEmpty ? nil : trimmedPhonetic)
        dismiss()
    }
}
