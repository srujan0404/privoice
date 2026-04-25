import SwiftUI
import UIKit

/// Onboarding step 2 — "Let's Unlock your Voice". Shows what enabling the
/// keyboard buys the user, then offers a CTA that opens iOS Settings → General →
/// Keyboards. Tapping the CTA also advances the flow so the user can continue
/// even if they decide to skip Settings for now.
struct KeyboardSetupView: View {
    let onNext: () -> Void

    private static let inkBlack = Color.black
    private static let subtitleGray = Color(red: 0x8E / 255.0, green: 0x8E / 255.0, blue: 0x93 / 255.0)
    private static let ctaBlue = Color(red: 0x00 / 255.0, green: 0x91 / 255.0, blue: 0xFF / 255.0)

    var body: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 44)

            VStack(spacing: 12) {
                Text("Let's Unlock\nyour Voice")
                    .font(.system(size: 40, weight: .bold, design: .rounded).leading(.tight))
                    .tracking(-0.6)
                    .foregroundStyle(Self.inkBlack)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text("One quick setup and your voice works everywhere — Messages, WhatsApp, email, and anywhere else you type. Your words stay on your device. Always.")
                    .font(.system(size: 18, weight: .semibold, design: .rounded).leading(.tight))
                    .foregroundStyle(Self.subtitleGray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer().frame(height: 12)

            keyboardsRow

            Spacer()

            ctaButton
                .padding(.bottom, 24)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    private var keyboardsRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "keyboard")
                .font(.system(size: 17))
                .foregroundStyle(Self.inkBlack)
                .frame(width: 28)
            Text("Keyboards")
                .font(AppFont.semibold(17))
                .foregroundStyle(Self.inkBlack)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(.systemGray3))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray6))
        )
    }

    private var ctaButton: some View {
        Button(action: handleTap) {
            HStack(spacing: 8) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 20, height: 20)
                Text("Go to Settings")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Self.ctaBlue, in: .capsule)
            .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }

    private func handleTap() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        onNext()
    }
}
