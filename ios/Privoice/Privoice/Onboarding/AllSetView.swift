import SwiftUI

/// Onboarding step 4 — "Privoice is Alive!" interstitial. Black canvas with
/// a centered headline + 40%-opacity subtitle, and a full-width white capsule
/// "Let's Go!" CTA at the bottom that advances the flow.
struct AllSetView: View {
    let onNext: () -> Void

    private static let gradientStop1 = Color(red: 0x1A / 255.0, green: 0x1A / 255.0, blue: 0x2E / 255.0)
    private static let gradientStop2 = Color(red: 0x16 / 255.0, green: 0x21 / 255.0, blue: 0x3E / 255.0)
    private static let gradientStop3 = Color(red: 0x0F / 255.0, green: 0x34 / 255.0, blue: 0x60 / 255.0)
    private static let gradientStop4 = Color(red: 0x1A / 255.0, green: 0x1A / 255.0, blue: 0x4E / 255.0)

    private static let canvasGradient = LinearGradient(
        stops: [
            .init(color: gradientStop1, location: 0.0),
            .init(color: gradientStop2, location: 0.4),
            .init(color: gradientStop3, location: 0.7),
            .init(color: gradientStop4, location: 1.0),
        ],
        startPoint: UnitPoint(x: 0.33, y: 0.0),
        endPoint: UnitPoint(x: 0.67, y: 1.0)
    )

    var body: some View {
        VStack(spacing: 16) {
            headerSection

            buttonSection
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Self.canvasGradient.ignoresSafeArea())
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Privoice\nis Alive!")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .tracking(-0.6)
                .lineSpacing(42 - 40)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text("Let\u{2019}s see what your voice can do.")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .lineSpacing(24 - 18)
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 64)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var buttonSection: some View {
        VStack {
            Button(action: onNext) {
                Text("Let\u{2019}s Go!")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.black)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 90)
                    .frame(maxWidth: .infinity)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 32))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
    }
}
