import SwiftUI

struct AvatarMenu: View {
    var size: CGFloat = 36

    var body: some View {
        Menu {
            SignOutButton()
        } label: {
            Circle()
                .fill(Color(.systemGray4))
                .frame(width: size, height: size)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: size * 0.5))
                        .foregroundStyle(.white)
                )
        }
    }
}
