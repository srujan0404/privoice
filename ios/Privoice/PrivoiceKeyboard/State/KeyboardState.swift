import Foundation
import Combine
import UIKit

enum KeyboardPhase: Equatable {
    case idle
    case listening
    case reviewing
    case polishing
}

@MainActor
final class ReviewEditorProxy {
    weak var textView: UITextView?
}

@MainActor
final class KeyboardState: ObservableObject {
    @Published var phase: KeyboardPhase = .idle
    let buffer: TranscriptBuffer
    let levelProvider: AudioLevelProvider
    let reviewEditor = ReviewEditorProxy()

    init() {
        self.buffer = TranscriptBuffer()
        self.levelProvider = AudioLevelProvider()
    }
}
