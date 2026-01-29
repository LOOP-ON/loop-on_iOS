//
//  AuthSecureField.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import Foundation
import SwiftUI

struct AuthSecureField: View {
    @Binding var text: String
    let placeholder: String
    @Binding var isVisible: Bool

    let textColorName: String
    let placeholderColorName: String
    let backgroundColorName: String
    let height: CGFloat

    var body: some View {
        HStack(spacing: 10) {
            Group {
                if isVisible {
                    TextField(
                        "",
                        text: $text,
                        prompt: Text(placeholder)
                            .font(.system(size: 14))
                            .foregroundStyle(Color(placeholderColorName))
                    )
                } else {
                    SecureField(
                        "",
                        text: $text,
                        prompt: Text(placeholder)
                            .font(.system(size: 14))
                            .foregroundStyle(Color(placeholderColorName))
                    )
                }
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .foregroundStyle(Color(textColorName))
            .submitLabel(.done)
            .textFieldStyle(.plain)

            Button { isVisible.toggle() } label: {
                Image(isVisible ? "visible" : "invisible")
                    .foregroundStyle(Color("45-Text"))
            }
            .accessibilityLabel(isVisible ? "비밀번호 숨기기" : "비밀번호 보기")
        }
        .padding(.horizontal, 14)
        .frame(height: height)
        .background(Color(backgroundColorName))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}


#Preview("AuthSecureField - Hidden") {
    AuthSecureFieldPreviewWrapper(startVisible: false)
        .padding()
        .background(Color(.systemGroupedBackground))
}

#Preview("AuthSecureField - Visible") {
    AuthSecureFieldPreviewWrapper(startVisible: true)
        .padding()
        .background(Color(.systemGroupedBackground))
}

private struct AuthSecureFieldPreviewWrapper: View {
    @State private var text: String = ""
    @State private var isVisible: Bool

    init(startVisible: Bool) {
        _isVisible = State(initialValue: startVisible)
    }

    var body: some View {
        AuthSecureField(
            text: $text,
            placeholder: "비밀번호 (영문, 숫자 포함 8~16자)",
            isVisible: $isVisible,
            textColorName: "25-Text",
            placeholderColorName: "45-Text",
            backgroundColorName: "background",
            height: 40
        )
    }
}
