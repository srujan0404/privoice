import SwiftUI
import AVFoundation

/// Onboarding step 3 — "Now let's give it ears." Shows a fake permission card
/// resembling iOS's system alert and triggers a real `requestRecordPermission`
/// call so the system prompt overlays. Either user choice advances the flow.
struct MicPermissionView: View {
    let onNext: () -> Void

    @State private var didRequest = false

    private static let subtitleGray = Color(red: 0x8E / 255.0, green: 0x8E / 255.0, blue: 0x93 / 255.0)
    private static let enabledGreen = Color(red: 0x34 / 255.0, green: 0xC7 / 255.0, blue: 0x59 / 255.0)
    private static let cardFill = Color(red: 0xF2 / 255.0, green: 0xF2 / 255.0, blue: 0xF7 / 255.0)
    private static let cardBodyGray = Color(red: 0x99 / 255.0, green: 0x99 / 255.0, blue: 0x99 / 255.0)
    private static let cardButtonFill = Color(red: 120 / 255.0, green: 120 / 255.0, blue: 128 / 255.0, opacity: 0.16)

    var body: some View {
        VStack(spacing: 16) {
            headerSection

            cardSection

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear { requestPermissionOnce() }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            keyboardEnabledPill

            Text("Now let's\ngive it ears.")
                .font(.system(size: 40, weight: .bold, design: .rounded).leading(.tight))
                .tracking(-0.6)
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text("We need microphone access to hear you, only when you tap the mic, never in the background.")
                .font(.system(size: 18, weight: .semibold, design: .rounded).leading(.tight))
                .foregroundStyle(Self.subtitleGray)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 8)
    }

    private var keyboardEnabledPill: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(Self.enabledGreen)
            Text("Keyboard Enabled")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Self.enabledGreen)
        }
    }

    private var cardSection: some View {
        VStack(spacing: 10) {
            permissionCard

            ZStack(alignment: .topLeading) {
                Color.clear.frame(width: 322, height: 72)
                Image("SquigglyArrow")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 97, height: 72)
                    .offset(x: 157)
            }
            .frame(width: 322)
        }
        .padding(.horizontal, 10)
    }

    private var permissionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image("MicHandIcon")
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .frame(width: 72, height: 72)
                .padding(4)

            VStack(alignment: .leading, spacing: 10) {
                Text("\u{201C}Privoice\u{201D} would like to access the Microphone.")
                    .font(.system(size: 17, weight: .semibold))
                    .tracking(-0.43)
                    .foregroundStyle(.black)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Pocket voice requires microphone access to transcribe speech to text.")
                    .font(.system(size: 17))
                    .tracking(-0.43)
                    .foregroundStyle(Self.cardBodyGray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
            .padding(.horizontal, 8)

            HStack(spacing: 8) {
                cardButton(title: "Don\u{2019}t Allow", action: onNext)
                cardButton(title: "Allow", action: onNext)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Self.cardFill)
        )
        .padding(6)
        .frame(width: 322)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .strokeBorder(Self.cardFill, lineWidth: 2)
        )
    }

    private func cardButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .medium))
                .tracking(-0.43)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Self.cardButtonFill, in: .capsule)
        }
        .buttonStyle(.plain)
    }

    private func requestPermissionOnce() {
        guard !didRequest else { return }
        didRequest = true
        AVAudioApplication.requestRecordPermission { _ in }
    }
}
