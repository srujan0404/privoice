import Foundation
import Observation
import PrivoiceCore
import UIKit
import GoogleSignIn

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

    func signInWithGoogle() async {
        errorMessage = nil
        guard let presenter = topViewController() else {
            errorMessage = "Couldn't present Google sign-in."
            return
        }
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
            guard let idToken = result.user.idToken?.tokenString else {
                errorMessage = "Google sign-in didn't return a token."
                return
            }
            let resp = try await AuthAPI.googleLogin(idToken: idToken)
            onAuthenticated(resp)
        } catch let api as APIError {
            errorMessage = api.userMessage
        } catch let nsError as NSError where nsError.domain == kGIDSignInErrorDomain && nsError.code == GIDSignInError.canceled.rawValue {
            // User dismissed the consent sheet — keep silent, no error to surface.
        } catch {
            errorMessage = "Google sign-in failed. Please try again."
        }
    }
}

@MainActor
private func topViewController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let activeScene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
    guard let window = activeScene?.keyWindow ?? activeScene?.windows.first(where: \.isKeyWindow) ?? activeScene?.windows.first else {
        return nil
    }
    var top = window.rootViewController
    while let presented = top?.presentedViewController { top = presented }
    return top
}
