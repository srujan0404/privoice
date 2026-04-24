import SwiftUI

struct SnippetsEmptyView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(minHeight: 60, maxHeight: 120)

            Image(systemName: "plus.square.on.square")
                .font(.system(size: 60, weight: .regular))
                .foregroundStyle(Color.accentColor)
                .padding(.bottom, 18)

            Text("No Snippets, yet")
                .font(.system(size: 22, weight: .semibold))
                .padding(.bottom, 10)

            VStack(spacing: 2) {
                Text("Say it short, Pocket voice types it long.")
                Text("Add a phrase and what it should expand to.")
            }
            .font(.system(size: 16))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

            Spacer().frame(minHeight: 48)

            HStack(spacing: 0) {
                Spacer()
                Image("NotesArrow")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 90)
                    .padding(.trailing, 100)
            }

            Spacer().frame(minHeight: 140)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
