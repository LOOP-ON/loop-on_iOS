//
//  ProfileTextField.swift
//  Loop_On
//
//  Created by Auto on 1/14/26.
//

import SwiftUI

struct ProfileTextField: View {
    @Binding var text: String
    let placeholder: String
    
    let textColorName: String
    let placeholderColorName: String
    let backgroundColorName: String
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
        .padding(.vertical, 12)
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(backgroundColorName))
        )
    }
}

#Preview("ProfileTextField - Empty") {
    ProfileTextFieldPreviewWrapper(initial: "")
        .padding()
        .background(Color(.systemGroupedBackground))
}

#Preview("ProfileTextField - Filled") {
    ProfileTextFieldPreviewWrapper(initial: "홍길동")
        .padding()
        .background(Color(.systemGroupedBackground))
}

private struct ProfileTextFieldPreviewWrapper: View {
    @State private var text: String
    
    init(initial: String) {
        _text = State(initialValue: initial)
    }
    
    var body: some View {
        ProfileTextField(
            text: $text,
            placeholder: "이름",
            textColorName: "25-Text",
            placeholderColorName: "45-Text",
            backgroundColorName: "background"
        )
    }
}
