import Foundation
import AVFoundation
import Combine

@MainActor
final class AudioLevelProvider: ObservableObject {
    @Published var level: Float = 0

    nonisolated func ingest(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frames = Int(buffer.frameLength)
        guard frames > 0 else { return }

        var sum: Float = 0
        for i in 0..<frames {
            let sample = channelData[i]
            sum += sample * sample
        }
        let rms = (sum / Float(frames)).squareRoot()

        let db = 20 * log10(max(rms, 1e-6))
        let normalized = max(0, min(1, (db + 50) / 50))

        Task { @MainActor in
            self.level = normalized
        }
    }

    func reset() {
        level = 0
    }
}
