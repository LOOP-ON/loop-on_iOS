//
//  AuthTextField.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import Foundation
import SwiftUI

struct AuthTextField: View {
    @Binding var text: String
    let placeholder: String

    let textColorName: String
    let placeholderColorName: String
    let backgroundColorName: String
    let height: CGFloat
    var keyboard: UIKeyboardType = .default

    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(placeholder).foregroundStyle(Color(placeholderColorName))
        )
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .keyboardType(keyboard)
        .foregroundStyle(Color(textColorName))
        .padding(.horizontal, 14)
        .frame(height: height)
        .background(Color(backgroundColorName))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}


#Preview("AuthTextField - Empty") {
    AuthTextFieldPreviewWrapper(initial: "")
        .padding()
        .background(Color(.systemGroupedBackground))
}

#Preview("AuthTextField - Filled") {
    AuthTextFieldPreviewWrapper(initial: "test@loopon.com")
        .padding()
        .background(Color(.systemGroupedBackground))
}

private struct AuthTextFieldPreviewWrapper: View {
    @State private var text: String

    init(initial: String) {
        _text = State(initialValue: initial)
    }

    var body: some View {
        AuthTextField(
            text: $text,
            placeholder: "이메일",
            textColorName: "25-Text",
            placeholderColorName: "45-Text",
            backgroundColorName: "background",
            height: 40,
            keyboard: .emailAddress
        )
    }
}

