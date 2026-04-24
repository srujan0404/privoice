import Foundation
import Combine

@MainActor
final class TranscriptBuffer: ObservableObject {
    @Published private(set) var finalized: String = ""
    @Published private(set) var partial: String = ""

    var full: String {
        if partial.isEmpty { return finalized }
        if finalized.isEmpty { return partial }
        return finalized + " " + partial
    }

    func updatePartial(_ text: String) {
        partial = text
    }

    func finalizePartial() {
        if !partial.isEmpty {
            finalized = finalized.isEmpty ? partial : (finalized + " " + partial)
            partial = ""
        }
    }

    func overwrite(_ text: String) {
        finalized = text
        partial = ""
    }

    func clear() {
        finalized = ""
        partial = ""
    }
}
