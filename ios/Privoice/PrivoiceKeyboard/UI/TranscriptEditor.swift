import SwiftUI
import UIKit

struct TranscriptEditor: UIViewRepresentable {
    @ObservedObject var buffer: TranscriptBuffer
    let proxy: ReviewEditorProxy

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.font = .preferredFont(forTextStyle: .body)
        tv.backgroundColor = .clear
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 4, bottom: 12, right: 4)
        tv.textContainer.lineFragmentPadding = 4
        tv.isEditable = true
        tv.isSelectable = true
        tv.autocorrectionType = .no
        tv.smartDashesType = .no
        tv.smartQuotesType = .no
        tv.smartInsertDeleteType = .no
        tv.inputView = UIView()
        tv.inputAssistantItem.leadingBarButtonGroups = []
        tv.inputAssistantItem.trailingBarButtonGroups = []
        tv.text = buffer.full
        tv.delegate = context.coordinator
        proxy.textView = tv
        DispatchQueue.main.async { [weak tv] in
            tv?.becomeFirstResponder()
            if let tv {
                let end = tv.endOfDocument
                tv.selectedTextRange = tv.textRange(from: end, to: end)
            }
        }
        return tv
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        proxy.textView = uiView
    }

    func makeCoordinator() -> Coordinator { Coordinator(buffer: buffer) }

    final class Coordinator: NSObject, UITextViewDelegate {
        let buffer: TranscriptBuffer
        init(buffer: TranscriptBuffer) { self.buffer = buffer }

        func textViewDidChange(_ textView: UITextView) {
            buffer.overwrite(textView.text ?? "")
        }
    }
}
