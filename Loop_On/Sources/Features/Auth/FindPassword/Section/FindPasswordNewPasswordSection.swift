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
                // 이메일/인증번호 필드와 동일하게 텍스트/플레이스홀더 색상 지정
                textColorName: "25-Text",
                placeholderColorName: "45-Text",
                backgroundColorName: "100",
                height: 40
            )
            
            // 비밀번호 재입력 필드
            AuthSecureField(
                text: $vm.confirmPassword,
                placeholder: "비밀번호 재입력",
                isVisible: $isConfirmPasswordVisible,
                // 이메일/인증번호 필드와 동일하게 텍스트/플레이스홀더 색상 지정
                textColorName: "25-Text",
                placeholderColorName: "45-Text",
                backgroundColorName: "100",
                height: 40
            )
            .padding(.top, 8)
            
            // Helper Text - "비밀번호 재입력" 입력 필드 바로 아래, 입력 필드 내부 텍스트와 왼쪽 정렬, 8px 간격
            // 헬퍼 텍스트가 차지하는 공간은 항상 유지하되,
            // 실제 메시지가 있을 때만 보이도록 처리
            let helperMessage = vm.passwordErrorMessage ?? vm.passwordMatchMessage
            
            Text(helperMessage ?? " ")
                .font(.system(size: 13))
                .foregroundStyle(
                    vm.passwordErrorMessage != nil ? Color("StatusRed") : Color("StatusGreen")
                )
                .opacity(helperMessage == nil ? 0 : 1) // 메시지 없을 때는 투명 처리
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
