import SwiftUI
import PrivoiceCore

struct NewSnippetView: View {
    let existing: Snippet?
    let onSubmit: (_ trigger: String, _ expansion: String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var triggerText: String
    @State private var expansionText: String
    @FocusState private var triggerFocused: Bool

    init(
        existing: Snippet? = nil,
        onSubmit: @escaping (_ trigger: String, _ expansion: String) -> Void
    ) {
        self.existing = existing
        self.onSubmit = onSubmit
        _triggerText = State(initialValue: existing?.trigger ?? "")
        _expansionText = State(initialValue: existing?.expansion ?? "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 24)
                .padding(.top, 20)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    fieldSection(
                        title: "When you say",
                        placeholder: "Eg. \u{201C}My Address\u{201D}"
                    ) {
                        TextField(
                            "",
                            text: $triggerText,
                            prompt: Text("Eg. \u{201C}My Address\u{201D}").foregroundColor(.secondary)
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
                                .strokeBorder(triggerFocused ? Color.accentColor : Color.clear, lineWidth: 1.8)
                        )
                        .focused($triggerFocused)
                    }

                    fieldSection(
                        title: "Privoice will type",
                        placeholder: "Eg. 7420 Evergreen Terrace, Springfield, IL 62702"
                    ) {
                        expansionEditor
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
                triggerFocused = true
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

            Text(existing == nil ? "New Snippet" : "Edit Snippet")
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

    private var expansionEditor: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
            if expansionText.isEmpty {
                Text("Eg. 7420 Evergreen Terrace, Springfield, IL 62702")
                    .font(.system(size: 17))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                    .allowsHitTesting(false)
            }
            TextEditor(text: $expansionText)
                .font(.system(size: 17))
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
        }
        .frame(minHeight: 160)
    }

    private func fieldSection<Content: View>(
        title: String,
        placeholder: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
            content()
        }
    }

    private var canSubmit: Bool {
        !triggerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !expansionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func submit() {
        guard canSubmit else { return }
        onSubmit(
            triggerText.trimmingCharacters(in: .whitespacesAndNewlines),
            expansionText.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        dismiss()
    }
}
