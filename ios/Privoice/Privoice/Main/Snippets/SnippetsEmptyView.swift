import SwiftUI

struct SnippetsEmptyView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(minHeight: 60, maxHeight: 120)

            Image("SnippetIcon")
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .frame(width: 72, height: 72)

            Text("No Snippets, yet")
                .font(AppFont.semibold(20))
                .tracking(-0.4)
                .foregroundStyle(Color(red: 0x0A / 255.0, green: 0x0A / 255.0, blue: 0x0A / 255.0))
                .padding(.top, 14)
                .padding(.bottom, 10)

            VStack(spacing: 2) {
                Text("Say it short, Privoice types it long.")
                Text("Add a phrase and what it should expand to.")
            }
            .font(AppFont.regular(15))
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
