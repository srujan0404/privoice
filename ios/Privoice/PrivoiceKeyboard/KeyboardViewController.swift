import UIKit

final class KeyboardViewController: UIInputViewController {
    private let label: UILabel = {
        let l = UILabel()
        l.text = "Privoice (coming soon)"
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 17, weight: .medium)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let nextKeyboardButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("⌨ Next Keyboard", for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(label)
        view.addSubview(nextKeyboardButton)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),

            nextKeyboardButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextKeyboardButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
        ])

        nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
    }
}
