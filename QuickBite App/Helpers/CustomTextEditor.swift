//
//  CustomTextEditor.swift
//  QuickBite App
//
//  Created by jessica tedja on 21/11/25.
//

import SwiftUI

struct CustomTextEditor: UIViewRepresentable {

    @Binding var text: String
    var wordLimit: Int = 100

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextEditor

        init(_ parent: CustomTextEditor) {
            self.parent = parent
        }

        // ✅ HARD BLOCK INPUT BEFORE IT ENTERS
        func textView(
            _ textView: UITextView,
            shouldChangeTextIn range: NSRange,
            replacementText replacement: String
        ) -> Bool {

            let currentText = textView.text ?? ""

            // ✅ Allow deleting always
            if replacement.isEmpty {
                return true
            }

            // ✅ Predict the future text
            guard let swiftRange = Range(range, in: currentText) else { return true }
            let updatedText = currentText.replacingCharacters(in: swiftRange, with: replacement)

            let wordCount = updatedText
                .split { $0.isWhitespace || $0.isNewline }
                .count

            // 🚫 HARD STOP once limit reached
            return wordCount <= parent.wordLimit
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.delegate = context.coordinator

        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0

        view.font = UIFont.systemFont(ofSize: 15)
        view.backgroundColor = .clear

        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }
}
