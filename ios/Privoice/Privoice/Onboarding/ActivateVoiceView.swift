import SwiftUI

/// Onboarding step 5 — "Activate your Voice". Title and subtitle pinned to
/// the top, a callout-style mock keyboard in the middle (representing the
/// iOS native keyboard before the user switches), and the user's actual
/// keyboard summoned at the bottom via a hidden first-responder text field.
/// The teaching gesture: long-press 🌐 in the real keyboard to switch to
/// PocketVoice. Advances when any text is typed via the real keyboard, or
/// when the user taps the mock keyboard graphic.
struct ActivateVoiceView: View {
    let onNext: () -> Void

    @State private var typed: String = ""
    @State private var hasAdvanced: Bool = false
    @State private var settleTask: Task<Void, Never>? = nil

    private static let inkBlack = Color(red: 0x0A / 255.0, green: 0x0A / 255.0, blue: 0x0A / 255.0)

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 40)

                Text("Activate your Voice")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .tracking(-0.42)
                    .foregroundStyle(Self.inkBlack)

                HStack(spacing: 4) {
                    Text("Hold the")
                    Image(systemName: "globe")
                        .foregroundStyle(.blue)
                    Text("on any keyboard to find")
                }
                .font(AppFont.regular(15))
                .foregroundStyle(Color(.systemGray))
                .padding(.top, 10)

                Text("PocketVoice. Always one press away.")
                    .font(AppFont.regular(15))
                    .foregroundStyle(Color(.systemGray))

                Spacer()

                Image("KeyboardMockNative")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 320)
                    .onTapGesture { advance() }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            KeyboardSummoner(text: $typed)
                .frame(width: 1, height: 1)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .onChange(of: typed) { _, newValue in
            scheduleAdvanceIfNeeded(for: newValue)
        }
        .onDisappear { settleTask?.cancel() }
    }

    private func advance() {
        guard !hasAdvanced else { return }
        hasAdvanced = true
        onNext()
    }

    private func scheduleAdvanceIfNeeded(for newValue: String) {
        guard !hasAdvanced,
              !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        settleTask?.cancel()
        settleTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 700_000_000)
            guard !Task.isCancelled, !hasAdvanced else { return }
            advance()
        }
    }
}

/// Pixel-faithful mock of an iOS keyboard for the onboarding teaching slides.
/// Two visual variants: `.nativeIOS` (ABC + space + return) and `.privoice`
/// (123 + emoji + space-with-label + return). Both share a predictive-text
/// strip ("The" / the / to) and a globe / mic footer row.
struct PrivoiceKeyboardMock: View {
    enum Variant { case nativeIOS, privoice }

    var variant: Variant = .privoice
    var spaceLabel: String = ""

    private let row1 = ["q","w","e","r","t","y","u","i","o","p"]
    private let row2 = ["a","s","d","f","g","h","j","k","l"]
    private let row3 = ["z","x","c","v","b","n","m"]

    private static let bgFill = Color(red: 0xD1 / 255.0, green: 0xD3 / 255.0, blue: 0xD9 / 255.0)
    private static let keyFill = Color.white
    private static let modKeyFill = Color(red: 0xAD / 255.0, green: 0xB3 / 255.0, blue: 0xBD / 255.0)
    private static let suggestionDivider = Color(red: 0x99 / 255.0, green: 0x9C / 255.0, blue: 0xA3 / 255.0).opacity(0.4)
    private static let returnFill = Color(red: 0x00 / 255.0, green: 0x91 / 255.0, blue: 0xFF / 255.0)

    var body: some View {
        VStack(spacing: 6) {
            predictiveStrip

            keyRow(row1)
            keyRow(row2).padding(.horizontal, 18)
            HStack(spacing: 6) {
                modKey(image: "shift", width: 36)
                keyRow(row3)
                modKey(image: "delete.left", width: 36)
            }
            bottomRow
            HStack {
                Image(systemName: "globe")
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "mic")
                    .foregroundStyle(.primary)
            }
            .font(.system(size: 18))
            .padding(.horizontal, 6)
            .padding(.top, 4)
        }
        .padding(8)
        .background(Self.bgFill, in: .rect(cornerRadius: 10))
    }

    @ViewBuilder
    private var bottomRow: some View {
        switch variant {
        case .nativeIOS:
            HStack(spacing: 6) {
                modKey(text: "ABC", width: 52)
                spaceBar
                returnKey
            }
        case .privoice:
            HStack(spacing: 6) {
                modKey(text: "123", width: 42)
                modKey(image: "face.smiling", width: 42)
                spaceBar
                returnKey
            }
        }
    }

    private var predictiveStrip: some View {
        HStack(spacing: 0) {
            suggestion("\u{201C}The\u{201D}")
            divider
            suggestion("the")
            divider
            suggestion("to")
        }
        .frame(height: 38)
    }

    private func suggestion(_ word: String) -> some View {
        Text(word)
            .font(.system(size: 15, weight: .regular))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(Self.suggestionDivider)
            .frame(width: 1, height: 22)
    }

    private func keyRow(_ keys: [String]) -> some View {
        HStack(spacing: 6) {
            ForEach(keys, id: \.self) { k in
                Text(k)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Self.keyFill, in: .rect(cornerRadius: 5))
                    .shadow(color: .black.opacity(0.12), radius: 0, x: 0, y: 1)
            }
        }
    }

    private func modKey(image: String? = nil, text: String? = nil, width: CGFloat) -> some View {
        Group {
            if let image {
                Image(systemName: image)
                    .font(.system(size: 14, weight: .regular))
            } else if let text {
                Text(text)
                    .font(.system(size: 13, weight: .regular))
            }
        }
        .foregroundStyle(.primary)
        .frame(width: width, height: 40)
        .background(Self.modKeyFill.opacity(0.4), in: .rect(cornerRadius: 5))
    }

    private var spaceBar: some View {
        Text(spaceLabel)
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(Self.keyFill, in: .rect(cornerRadius: 5))
    }

    private var returnKey: some View {
        Image(systemName: "return")
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 56, height: 40)
            .background(Self.returnFill, in: .rect(cornerRadius: 5))
    }
}

/// Backwards-compatible alias — older onboarding views referenced
/// `MockKeyboard`; the new `PrivoiceKeyboardMock` supersedes it.
typealias MockKeyboard = PrivoiceKeyboardMock
