import Foundation
import AVFoundation
import Speech

enum PermissionResult {
    case ready
    case micDenied
    case speechDenied
    case noFullAccess
}

@MainActor
final class PermissionController {
    let hasFullAccess: () -> Bool

    init(hasFullAccess: @escaping () -> Bool) {
        self.hasFullAccess = hasFullAccess
    }

    func ensureReady() async -> PermissionResult {
        guard hasFullAccess() else { return .noFullAccess }

        let micGranted: Bool
        if #available(iOS 17.0, *) {
            micGranted = await AVAudioApplication.requestRecordPermission()
        } else {
            micGranted = await withCheckedContinuation { cont in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    cont.resume(returning: granted)
                }
            }
        }
        if !micGranted { return .micDenied }

        let speechStatus: SFSpeechRecognizerAuthorizationStatus = await withCheckedContinuation { cont in
            SFSpeechRecognizer.requestAuthorization { status in
                cont.resume(returning: status)
            }
        }
        guard speechStatus == .authorized else { return .speechDenied }

        return .ready
    }
}
