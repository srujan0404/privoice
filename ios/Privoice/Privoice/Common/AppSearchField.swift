import SwiftUI

/// Pill-shaped search field matching the Figma search style.
/// Used in place of `.searchable` so the title row can stay inline with the avatar.
struct AppSearchField: View {
    @Binding var text: String
    var placeholder: String = "Search"

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)

            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.secondary))
                .font(AppFont.regular(16))
                .textFieldStyle(.plain)
                .submitLabel(.search)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.systemGray5), in: .capsule)
    }
}
