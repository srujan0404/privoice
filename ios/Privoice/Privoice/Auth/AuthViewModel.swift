import Foundation
import Observation
import PrivoiceCore
import UIKit
import GoogleSignIn

@Observable
@MainActor
final class AuthViewModel {
    var isSubmitting: Bool = false
    var errorMessage: String?

    private let onAuthenticated: @MainActor (AuthResponse) -> Void

    init(onAuthenticated: @escaping @MainActor (AuthResponse) -> Void) {
        self.onAuthenticated = onAuthenticated
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
            // User dismissed the consent sheet — silent.
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
