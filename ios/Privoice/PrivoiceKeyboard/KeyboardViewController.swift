import UIKit
import SwiftUI
import OSLog
import KeyboardKit
import PrivoiceCore

private let log = Logger(subsystem: "com.privoice.app.PrivoiceKeyboard", category: "Keyboard")

final class KeyboardViewController: KeyboardInputViewController {
    private lazy var appState = KeyboardState()
    private lazy var permissions = PermissionController(hasFullAccess: { [weak self] in
        self?.hasFullAccess ?? false
    })
    private lazy var speech = SpeechController(buffer: appState.buffer, levelProvider: appState.levelProvider)

    override func insertText(_ text: String) {
        if appState.phase == .reviewing, let tv = appState.reviewEditor.textView {
            tv.insertText(text)
            return
        }
        super.insertText(text)
    }

    override func deleteBackward() {
        if appState.phase == .reviewing, let tv = appState.reviewEditor.textView {
            tv.deleteBackward()
            return
        }
        super.deleteBackward()
    }

    override func viewWillSetupKeyboardView() {
        super.viewWillSetupKeyboardView()
        setupKeyboardView { [weak self] controller in
            guard let self else { return AnyView(EmptyView()) }
            return AnyView(
                KeyboardRootView(
                    services: controller.services,
                    appState: self.appState,
                    onMicTap: { [weak self] in Task { await self?.startListening() } },
                    onCancel: { [weak self] in self?.cancel() },
                    onConfirm: { [weak self] in self?.confirm() },
                    onDismissToReview: { [weak self] in self?.dismissToReview() }
                )
            )
        }
    }

    private func startListening() async {
        let result = await permissions.ensureReady()
        guard result == .ready else {
            log.error("permission not ready: \(String(describing: result))")
            return
        }
        do {
            try speech.start()
            appState.phase = .listening
        } catch {
            log.error("speech start failed: \(error.localizedDescription)")
            appState.phase = .idle
        }
    }

    private func cancel() {
        speech.stop()
        appState.buffer.clear()
        appState.phase = .idle
    }

    private func confirm() {
        speech.stop()
        let rawText = appState.buffer.full
        if rawText.isEmpty {
            appState.buffer.clear()
            appState.phase = .idle
            return
        }

        appState.phase = .polishing
        let hostProxy = originalTextDocumentProxy

        Task { [weak self] in
            guard let self else { return }
            let tone = TonePreference.shared.current
            let inserted: String
            do {
                let response = try await withTimeout(seconds: 10) {
                    try await PolishAPI.polish(transcript: rawText, tone: tone)
                }
                inserted = response.polishedText
            } catch {
                log.error("polish failed, falling back to raw: \(error.localizedDescription)")
                inserted = rawText
            }
            await MainActor.run {
                hostProxy.insertText(inserted)
                self.appState.buffer.clear()
                self.appState.phase = .idle
            }
        }
    }

    private func dismissToReview() {
        speech.stop()
        appState.phase = .reviewing
    }

    private func withTimeout<T: Sendable>(seconds: TimeInterval, operation: @escaping @Sendable () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw APIError.network("timeout")
            }
            guard let result = try await group.next() else {
                throw APIError.network("timeout")
            }
            group.cancelAll()
            return result
        }
    }
}

struct KeyboardRootView: View {
    let services: Keyboard.Services
    @ObservedObject var appState: KeyboardState
    let onMicTap: () -> Void
    let onCancel: () -> Void
    let onConfirm: () -> Void
    let onDismissToReview: () -> Void

    var body: some View {
        switch appState.phase {
        case .idle:
            idleLayout
        case .listening:
            ListeningOverlayView(
                buffer: appState.buffer,
                level: appState.levelProvider,
                onCancel: onCancel,
                onConfirm: onConfirm,
                onDismissToReview: onDismissToReview
            )
        case .reviewing:
            reviewingLayout
        case .polishing:
            polishingLayout
        }
    }

    private var idleLayout: some View {
        KeyboardView(
            services: services,
            buttonContent: { $0.view },
            buttonView: { $0.view },
            collapsedView: { $0.view },
            emojiKeyboard: { $0.view },
            toolbar: { _ in
                HStack(spacing: 0) {
                    Text("PRIVOICE")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .padding(.leading, 12)
                    Spacer()
                    MicButton(action: onMicTap)
                        .padding(.trailing, 8)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
            }
        )
    }

    private var reviewingLayout: some View {
        VStack(spacing: 0) {
            TranscriptPreviewView(
                buffer: appState.buffer,
                reviewEditor: appState.reviewEditor,
                onCancel: onCancel,
                onConfirm: onConfirm
            )
            KeyboardView(
                services: services,
                buttonContent: { $0.view },
                buttonView: { $0.view },
                collapsedView: { $0.view },
                emojiKeyboard: { $0.view },
                toolbar: { _ in EmptyView() }
            )
        }
    }

    private var polishingLayout: some View {
        VStack(spacing: 0) {
            ProgressView().controlSize(.large).frame(height: 60)
            KeyboardView(
                services: services,
                buttonContent: { $0.view },
                buttonView: { $0.view },
                collapsedView: { $0.view },
                emojiKeyboard: { $0.view },
                toolbar: { _ in EmptyView() }
            )
            .opacity(0.4)
            .disabled(true)
        }
    }
}
