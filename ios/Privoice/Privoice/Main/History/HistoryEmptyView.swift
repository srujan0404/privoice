import SwiftUI

struct HistoryEmptyView: View {
    var body: some View {
        VStack(spacing: 14) {
            Spacer()
            Image("HistoryEmpty")
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .frame(width: 72, height: 72)
                .padding(.bottom, 4)

            // CSS: SF Pro Rounded 600, 20/24, -0.02em, #0A0A0A
            Text("There's nothing here, yet")
                .font(AppFont.semibold(20))
                .tracking(-0.4)
                .foregroundStyle(Color(red: 0x0A / 255.0, green: 0x0A / 255.0, blue: 0x0A / 255.0))

            Text("Your pocket voice history will appear here once you start sending messages.")
                .font(AppFont.regular(15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 32)
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
