//
//  CustomTextEditor.swift
//  QuickBite App
//
//  Created by jessica tedja on 21/11/25.
//

import SwiftUI

struct CustomTextEditor: UIViewRepresentable {

    @Binding var text: String

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextEditor

        init(_ parent: CustomTextEditor) {
            self.parent = parent
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

        // REMOVE ALL DEFAULT PADDING
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0

        view.font = UIFont.systemFont(ofSize: 15)
        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }
}
