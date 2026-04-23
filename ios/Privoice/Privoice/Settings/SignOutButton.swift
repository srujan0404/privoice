import SwiftUI

struct SignOutButton: View {
    @Environment(AppState.self) private var appState
    @State private var isSigningOut = false

    var body: some View {
        Button(role: .destructive) {
            Task {
                isSigningOut = true
                await appState.signOut()
                isSigningOut = false
            }
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text(isSigningOut ? "Signing out…" : "Sign Out")
            }
        }
        .disabled(isSigningOut)
    }
}
