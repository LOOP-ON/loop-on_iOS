//
//  FindPasswordEmailVerificationSection.swift
//  Loop_On
//
//  Created by Auto on 1/14/26.
//

import SwiftUI

struct FindPasswordEmailVerificationSection: View {
    @ObservedObject var vm: FindPasswordViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 이메일 입력 필드와 인증 요청 버튼
            HStack(spacing: 8) {
                AuthTextField(
                    text: $vm.email,
                    placeholder: "이메일",
                    textColorName: "25-Text",
                    // 플레이스홀더도 더 진한 25-Text로 설정해서 항상 잘 보이도록
                    placeholderColorName: "45-Text",
                    backgroundColorName: "100",
                    height: 40,
                    keyboard: .emailAddress
                )
                
                Button(action: {
                    vm.requestVerification()
                }) {
                    Text("인증 요청")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color("100")) // 텍스트 자체를 항상 그레이스케일 100으로 고정
                        .frame(height: 40)
                        .padding(.horizontal, 12)
                }
                .buttonStyle(.plain)
                .background(vm.canRequestVerification ? Color("PrimaryColor55") : Color("85"))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                // 시스템 disabled 스타일을 쓰지 않고 터치만 막아서 텍스트 컬러는 유지
                .allowsHitTesting(vm.canRequestVerification)
                .fixedSize(horizontal: true, vertical: false)
            }
            
            // 인증번호 입력 필드와 확인 버튼
            HStack(spacing: 8) {
                ZStack(alignment: .trailing) {
                    AuthTextField(
                        text: $vm.verificationCode,
                        placeholder: "인증번호",
                        textColorName: "25-Text",
                        // 이메일 필드와 동일하게 플레이스홀더 색상도 25-Text로 맞춤
                        placeholderColorName: "45-Text",
                        backgroundColorName: "100",
                        height: 40,
                        keyboard: .numberPad,
                        isDisabled: false // disabled를 사용하지 않음
                    )
                    // opacity로 흐리게 만들지 않고, 이메일 필드와 동일한 명도 유지
                    .allowsHitTesting(vm.isVerificationRequested && !vm.isVerificationCodeVerified) // 터치만 막음
                    
                    // 체크마크 또는 타이머 (필드 내부 오른쪽에 표시, 동일한 너비로 고정)
                    HStack {
                        Spacer()
                        Group {
                            if vm.isVerificationCodeVerified {
                                // 체크마크 (인증 성공 시)
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color("StatusGreen"))
                                    .font(.system(size: 16))
                            } else if vm.isVerificationRequested && vm.remainingTime > 0 {
                                // 타이머 (인증 요청 후, 인증 완료 전)
                                Text(vm.timerString)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color("25-Text"))
                            }
                        }
                        .frame(width: 50, height: 16, alignment: .trailing) // 타이머 너비와 동일하게 고정
                        .padding(.trailing, 14)
                    }
                }
                
                Button(action: {
                    if vm.canVerifyCode && !vm.isVerificationCodeVerified {
                        vm.verifyCode()
                    }
                }) {
                    if vm.isVerifyingCode {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color("100")))
                            .frame(width: 60, height: 40)
                    } else {
                        Text("확인")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color("100"))
                            .frame(height: 40)
                            .padding(.horizontal, 8)
                    }
                }
                .buttonStyle(.plain)
                .background(vm.canVerifyCode || vm.isVerificationCodeVerified ? Color("PrimaryColor55") : Color("85"))
                .foregroundStyle(Color("100")) // 텍스트 색상 강제 유지
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .allowsHitTesting(vm.canVerifyCode && !vm.isVerificationCodeVerified) // disabled 대신 allowsHitTesting 사용
                .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.top, 8)
            
            // Helper Text - "인증번호" 입력 필드 바로 아래, 입력 필드 내부 텍스트와 왼쪽 정렬, 10px 간격
            // 헬퍼 텍스트가 차지하는 공간은 항상 유지하되,
            // 실제 메시지가 있을 때만 보이도록 처리
            let helperMessage = vm.emailErrorMessage
                ?? vm.verificationErrorMessage
                ?? vm.verificationSuccessMessage
                ?? vm.verificationCodeSentMessage
            
            Text(helperMessage ?? " ")
                .font(.system(size: 13))
                .foregroundStyle(
                    helperMessage == vm.verificationSuccessMessage
                    ? Color("StatusGreen")
                    : Color("45-Text")
                )
                .opacity(helperMessage == nil ? 0 : 1) // 없을 때는 보이지 않지만, 레이아웃 공간은 유지
                .padding(.leading, 14) // 입력 필드 내부 패딩과 동일하게 맞춤
                .padding(.top, 10)
        }
    }
}

#Preview("FindPasswordEmailVerificationSection") {
    FindPasswordEmailVerificationSectionPreviewWrapper()
        .padding()
        .background(Color("background"))
}

private struct FindPasswordEmailVerificationSectionPreviewWrapper: View {
    @StateObject private var vm = FindPasswordViewModel()
    
    var body: some View {
        FindPasswordEmailVerificationSection(vm: vm)
    }
}
