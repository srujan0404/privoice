import SwiftUI
import UIKit

/// Hosts an invisible UITextField that becomes first responder shortly after
/// the SwiftUI view it's embedded in appears, summoning the user's currently
/// active keyboard (Privoice if they've switched to it, system otherwise).
/// Inserted text flows back through the `text` binding.
struct KeyboardSummoner: UIViewControllerRepresentable {
    @Binding var text: String
    var autoFocus: Bool = true

    func makeUIViewController(context: Context) -> SummonerVC {
        let vc = SummonerVC()
        vc.autoFocus = autoFocus
        vc.onTextChange = { value in
            if context.coordinator.lastText != value {
                context.coordinator.lastText = value
                DispatchQueue.main.async {
                    if text != value { text = value }
                }
            }
        }
        return vc
    }

    func updateUIViewController(_ vc: SummonerVC, context: Context) {
        if (vc.textField.text ?? "") != text {
            vc.textField.text = text
            context.coordinator.lastText = text
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        var lastText: String = ""
    }

    final class SummonerVC: UIViewController {
        let textField = UITextField()
        var autoFocus = true
        var hasFocused = false
        var onTextChange: ((String) -> Void)?

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .clear

            textField.alpha = 0.001
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
            textField.spellCheckingType = .yes
            textField.returnKeyType = .send
            textField.tintColor = .clear
            textField.textColor = .clear
            textField.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(textField)
            NSLayoutConstraint.activate([
                textField.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                textField.topAnchor.constraint(equalTo: view.topAnchor),
                textField.widthAnchor.constraint(equalToConstant: 1),
                textField.heightAnchor.constraint(equalToConstant: 1),
            ])
            textField.addTarget(self, action: #selector(changed), for: .editingChanged)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.tryFocus()
            }
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            tryFocus()
        }

        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            if parent != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.tryFocus()
                }
            }
        }

        private func tryFocus() {
            guard autoFocus, !hasFocused, view.window != nil else { return }
            hasFocused = true
            textField.becomeFirstResponder()
        }

        @objc private func changed() {
            onTextChange?(textField.text ?? "")
        }
    }
}
