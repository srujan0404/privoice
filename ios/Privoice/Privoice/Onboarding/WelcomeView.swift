import SwiftUI
import PrivoiceCore

/// Onboarding step 1 — welcome / sign-in entry point.
struct WelcomeView: View {
    @Environment(AppState.self) private var appState
    @State private var vm: AuthViewModel?

    private static let inkBlack = Color(red: 0x0A / 255.0, green: 0x0A / 255.0, blue: 0x0A / 255.0)
    private static let footerGrayLight = Color(red: 0xBF / 255.0, green: 0xBF / 255.0, blue: 0xBF / 255.0)
    private static let footerGrayDark = Color(red: 0x72 / 255.0, green: 0x72 / 255.0, blue: 0x72 / 255.0)

    var body: some View {
        VStack(spacing: 16) {
            bodySection
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            buttonsSection

            footerTerms
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            if vm == nil {
                vm = AuthViewModel { response in
                    appState.signIn(with: response)
                }
            }
        }
    }

    private var bodySection: some View {
        VStack(spacing: 12) {
            Text("Privoice")
                .font(AppFont.semibold(18))
                .foregroundStyle(Color(.systemGray))

            Text("Starting today, your voice just became your fastest keyboard. |")
                .font(.system(size: 32, weight: .bold, design: .rounded).leading(.tight))
                .tracking(-0.48) // -1.5% of 32pt
                .foregroundStyle(Self.inkBlack)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 64)
    }

    private var buttonsSection: some View {
        VStack(spacing: 8) {
            providerButton(label: "Continue with Google", logo: "GoogleLogo") {
                Task { await vm?.signInWithGoogle() }
            }
            providerButton(label: "Continue with Apple", logo: "AppleLogo") {
                // Sign in with Apple isn't wired yet — placeholder action so the
                // button renders identically to the Figma. To be implemented later.
            }
        }
        .padding(.horizontal, 8)
    }

    private func providerButton(label: String, logo: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(logo)
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
                Text(label)
                    .font(AppFont.semibold(17))
                    .foregroundStyle(Self.inkBlack)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color(.systemGray6), in: .capsule)
        }
        .buttonStyle(.plain)
        .disabled(vm?.isSubmitting == true)
    }

    private var footerTerms: some View {
        let intro = Text("By signing up, you agree to the\n")
            .foregroundStyle(Self.footerGrayLight)
        let terms = Text("Terms of Service")
            .foregroundStyle(Self.footerGrayDark)
        let andWord = Text(" and ")
            .foregroundStyle(Self.footerGrayLight)
        let privacy = Text("Privacy Policy.")
            .foregroundStyle(Self.footerGrayDark)

        return (intro + terms + andWord + privacy)
            .font(AppFont.semibold(15))
            .tracking(-0.15)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
    }
}
