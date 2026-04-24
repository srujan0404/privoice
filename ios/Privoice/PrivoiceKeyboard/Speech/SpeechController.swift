import Foundation
import AVFoundation
import Speech

enum SpeechError: Error {
    case recognizerUnavailable
    case audioSessionFailed(Error)
    case recognitionFailed(Error)
}

@MainActor
final class SpeechController {
    private let buffer: TranscriptBuffer
    private let levelProvider: AudioLevelProvider

    private let audioEngine = AVAudioEngine()
    private var recognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var currentTaskID: UUID?
    private var isRestarting = false
    private var isStopped = true

    var isRunning: Bool { audioEngine.isRunning }

    init(buffer: TranscriptBuffer, levelProvider: AudioLevelProvider) {
        self.buffer = buffer
        self.levelProvider = levelProvider
    }

    func start() throws {
        isStopped = false
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        guard let recognizer, recognizer.isAvailable else {
            throw SpeechError.recognizerUnavailable
        }

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            throw SpeechError.audioSessionFailed(error)
        }

        startAudioCapture()
        try startRecognitionTask(recognizer: recognizer)
    }

    func stop() {
        isStopped = true
        currentTaskID = nil
        buffer.finalizePartial()
        task?.cancel()
        task = nil
        request?.endAudio()
        request = nil
        audioEngine.inputNode.removeTap(onBus: 0)
        if audioEngine.isRunning { audioEngine.stop() }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        levelProvider.reset()
    }

    private func startAudioCapture() {
        let node = audioEngine.inputNode
        let format = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            Task { @MainActor [weak self] in
                self?.request?.append(buffer)
            }
            self?.levelProvider.ingest(buffer)
        }
        audioEngine.prepare()
        try? audioEngine.start()
    }

    private func startRecognitionTask(recognizer: SFSpeechRecognizer) throws {
        let id = UUID()
        currentTaskID = id
        let req = SFSpeechAudioBufferRecognitionRequest()
        req.requiresOnDeviceRecognition = true
        req.shouldReportPartialResults = true
        self.request = req

        task = recognizer.recognitionTask(with: req) { [weak self] result, error in
            guard let self else { return }
            Task { @MainActor in
                guard self.currentTaskID == id else { return }
                self.handle(result: result, error: error, recognizer: recognizer)
            }
        }
    }

    private func handle(result: SFSpeechRecognitionResult?, error: Error?, recognizer: SFSpeechRecognizer) {
        if isStopped { return }

        if let result {
            let text = result.bestTranscription.formattedString
            if !text.isEmpty {
                buffer.updatePartial(text)
            }

            if result.isFinal {
                buffer.finalizePartial()
                if !isRestarting, audioEngine.isRunning {
                    restartRecognition(with: recognizer)
                }
            }
        }
        if error != nil, !isRestarting, audioEngine.isRunning {
            restartRecognition(with: recognizer)
        }
    }

    private func restartRecognition(with recognizer: SFSpeechRecognizer) {
        isRestarting = true
        defer { isRestarting = false }

        currentTaskID = nil
        task?.cancel()
        task = nil
        request?.endAudio()
        request = nil

        try? startRecognitionTask(recognizer: recognizer)
    }
}
