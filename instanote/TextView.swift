//
//  TextView.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/24/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import Foundation
import SwiftUI

struct TextView: UIViewRepresentable {

    class Coordinator: NSObject, UITextViewDelegate {
        let parent: TextView

        init(_ parent: TextView) {
            self.parent = parent
        }
 
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
            parent.selectedText = URL.absoluteString
            return false
        }
    }
    
    @Binding var text: NSAttributedString
    @Binding var selectedText: String

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.dataDetectorTypes = .all
        view.isEditable = false
        view.isUserInteractionEnabled = true
        view.delegate = context.coordinator
        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        var linkAttributes = [NSAttributedString.Key : Any]()
        linkAttributes[.font] = UIFont.preferredFont(forTextStyle: .body)
        linkAttributes[.foregroundColor] = UIColor.white

        uiView.linkTextAttributes = linkAttributes
        uiView.attributedText = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
