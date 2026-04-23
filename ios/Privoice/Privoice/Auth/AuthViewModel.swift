import Foundation
import Observation
import PrivoiceCore

@Observable
@MainActor
final class AuthViewModel {
    enum Mode { case signIn, register }

    var mode: Mode = .signIn
    var email: String = ""
    var password: String = ""
    var displayName: String = ""
    var isSubmitting: Bool = false
    var errorMessage: String?

    private let onAuthenticated: @MainActor (AuthResponse) -> Void

    init(onAuthenticated: @escaping @MainActor (AuthResponse) -> Void) {
        self.onAuthenticated = onAuthenticated
    }

    var canSubmit: Bool {
        switch mode {
        case .signIn:
            return !email.isEmpty && password.count >= 1 && !isSubmitting
        case .register:
            return !email.isEmpty && password.count >= 8 && !displayName.isEmpty && !isSubmitting
        }
    }

    func submit() async {
        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let resp: AuthResponse
            switch mode {
            case .signIn:
                resp = try await AuthAPI.login(email: email, password: password)
            case .register:
                resp = try await AuthAPI.register(email: email, password: password, displayName: displayName)
            }
            onAuthenticated(resp)
        } catch let api as APIError {
            errorMessage = api.userMessage
        } catch {
            errorMessage = "Something went wrong. Please try again."
        }
    }
}
