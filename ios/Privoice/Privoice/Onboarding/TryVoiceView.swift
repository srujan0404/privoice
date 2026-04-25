import SwiftUI

/// Onboarding step 6 + 7 — "Try your Voice". A hidden UITextField becomes
/// first responder so the user's actual keyboard (Privoice if active, system
/// otherwise) slides up. The user voice-types via the keyboard's mic; once
/// text is inserted into the field we animate the dashed reply target into a
/// solid sent bubble holding their text, then call onNext to finish onboarding.
struct TryVoiceView: View {
    let onNext: () -> Void

    @State private var enteredText: String = ""
    @State private var hasCompleted: Bool = false
    @State private var settleTask: Task<Void, Never>? = nil

    private static let inkBlack = Color(red: 0x0A / 255.0, green: 0x0A / 255.0, blue: 0x0A / 255.0)
    private static let bubbleGray = Color(red: 0xE5 / 255.0, green: 0xE5 / 255.0, blue: 0xEA / 255.0)
    private static let demoReply = "Yeah we\u{2019}re still on, how about that Italian place on 5th street? I can be there by 7!"

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                stepIndicator
                    .padding(.top, 32)

                Text("Try your Voice")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .tracking(-0.42)
                    .foregroundStyle(Self.inkBlack)
                    .padding(.top, 18)

                instructionText
                    .padding(.top, 10)
                    .padding(.horizontal, 32)

                Spacer().frame(height: 28)

                chatBubble
                    .padding(.horizontal, 24)

                Spacer().frame(height: 18)

                replyArea
                    .padding(.horizontal, 24)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            KeyboardSummoner(text: $enteredText)
                .frame(width: 1, height: 1)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .onChange(of: enteredText) { _, newValue in
            scheduleCompletionIfNeeded(for: newValue)
        }
        .onDisappear {
            settleTask?.cancel()
        }
    }

    private var stepIndicator: some View {
        HStack(spacing: 6) {
            Capsule().fill(Color.accentColor).frame(width: 32, height: 4)
            Capsule().fill(Color.accentColor.opacity(0.25)).frame(width: 18, height: 4)
            Capsule().fill(Color.accentColor.opacity(0.25)).frame(width: 18, height: 4)
            Capsule().fill(Color.accentColor.opacity(0.25)).frame(width: 18, height: 4)
        }
    }

    private var instructionText: some View {
        VStack(spacing: 2) {
            Text("Tap the mic button and respond,")
                .font(AppFont.regular(15))
                .foregroundStyle(Color(.systemGray))
            HStack(spacing: 4) {
                Text("click")
                    .foregroundStyle(Color(.systemGray))
                Text("\u{201C}")
                    .foregroundStyle(.primary)
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(Color.accentColor)
                Text("\u{201D}")
                    .foregroundStyle(.primary)
                Text("when you\u{2019}re done to send.")
                    .foregroundStyle(Color(.systemGray))
            }
            .font(AppFont.regular(15))
        }
    }

    private var chatBubble: some View {
        HStack {
            Text("Hey, are we still on for dinner tonight? Let me know where you want to go!")
                .font(AppFont.regular(15))
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Self.bubbleGray, in: .rect(cornerRadius: 16))
                .frame(maxWidth: 260, alignment: .leading)
            Spacer()
        }
    }

    @ViewBuilder
    private var replyArea: some View {
        if hasCompleted {
            sentBubble
                .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .bottomTrailing)))
        } else {
            replyPlaceholder
                .transition(.opacity)
        }
    }

    private var replyPlaceholder: some View {
        HStack {
            Spacer()
            Text(Self.demoReply)
                .font(AppFont.regular(15))
                .foregroundStyle(Color(.systemGray))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: 260, alignment: .leading)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color(.systemGray3), style: StrokeStyle(lineWidth: 1.2, dash: [4, 4]))
                )
        }
    }

    private var sentBubble: some View {
        HStack {
            Spacer()
            Text(enteredText.isEmpty ? Self.demoReply : enteredText)
                .font(AppFont.regular(15))
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Self.bubbleGray, in: .rect(cornerRadius: 16))
                .frame(maxWidth: 260, alignment: .leading)
        }
    }

    private func scheduleCompletionIfNeeded(for newValue: String) {
        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !hasCompleted else { return }

        settleTask?.cancel()
        settleTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 700_000_000)
            guard !Task.isCancelled,
                  enteredText.trimmingCharacters(in: .whitespacesAndNewlines) == trimmed,
                  !hasCompleted else { return }

            guard Self.matchesDemoLine(trimmed) else {
                try? await Task.sleep(nanoseconds: 400_000_000)
                guard !Task.isCancelled else { return }
                enteredText = ""
                return
            }

            withAnimation(.easeInOut(duration: 0.35)) {
                hasCompleted = true
            }

            try? await Task.sleep(nanoseconds: 1_400_000_000)
            guard !Task.isCancelled else { return }
            onNext()
        }
    }

    /// Fuzzy match — accepts polished/transcribed variations of the demo line
    /// as long as the three load-bearing tokens are present: "italian",
    /// "5th"/"fifth", and a "7"/"seven". Rejects unrelated content so the
    /// onboarding only advances when the user actually voiced the prompt.
    private static func matchesDemoLine(_ text: String) -> Bool {
        let lower = text.lowercased()
        let hasItalian = lower.contains("italian")
        let hasFifth = lower.contains("5th") || lower.contains("fifth")
        let hasSeven = lower.range(of: "\\b7\\b", options: .regularExpression) != nil
            || lower.contains("seven")
        return hasItalian && hasFifth && hasSeven
    }
}

