//
//  FindPasswordNewPasswordSection.swift
//  Loop_On
//
//  Created by Auto on 1/14/26.
//

import SwiftUI

struct FindPasswordNewPasswordSection: View {
    @ObservedObject var vm: FindPasswordViewModel
    @State private var isNewPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 새 비밀번호 입력 필드
            AuthSecureField(
                text: $vm.newPassword,
                placeholder: "비밀번호 (영문, 숫자 포함 8~16자)",
                isVisible: $isNewPasswordVisible,
                textColorName: "25-Text",
                placeholderColorName: "45-Text",
                backgroundColorName: "100",
                height: 40
            )
            .disabled(!vm.isVerificationCodeVerified)
            .opacity(vm.isVerificationCodeVerified ? 1 : 0.7)
            
            // 비밀번호 재입력 필드
            AuthSecureField(
                text: $vm.confirmPassword,
                placeholder: "비밀번호 재입력",
                isVisible: $isConfirmPasswordVisible,
                textColorName: "25-Text",
                placeholderColorName: "45-Text",
                backgroundColorName: "100",
                height: 40
            )
            .disabled(!vm.isVerificationCodeVerified)
            .opacity(vm.isVerificationCodeVerified ? 1 : 0.7)
            .padding(.top, 8)
            
            // Helper Text - "비밀번호 재입력" 입력 필드 바로 아래, 입력 필드 내부 텍스트와 왼쪽 정렬, 8px 간격
            Group {
                if let errorMessage = vm.passwordErrorMessage {
                    // 에러 메시지
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(Color("StatusRed"))
                } else if let matchMessage = vm.passwordMatchMessage {
                    // 비밀번호 일치 메시지 (파란색)
                    Text(matchMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.blue)
                } else {
                    // 기본 Helper Text
                    Text("Helper Text")
                        .font(.system(size: 13))
                        .foregroundStyle(Color("45-Text"))
                }
            }
            .padding(.leading, 14) // 입력 필드 내부 패딩과 동일하게 맞춤
            .padding(.top, 8)
        }
    }
}

#Preview("FindPasswordNewPasswordSection") {
    FindPasswordNewPasswordSectionPreviewWrapper()
        .padding()
        .background(Color("background"))
}

private struct FindPasswordNewPasswordSectionPreviewWrapper: View {
    @StateObject private var vm = FindPasswordViewModel()
    
    var body: some View {
        FindPasswordNewPasswordSection(vm: vm)
    }
}
