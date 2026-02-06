//
//  ProfileFormSection.swift
//  Loop_On
//
//  Created by Auto on 1/14/26.
//

import SwiftUI

struct ProfileFormSection: View {
    @ObservedObject var vm: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 닉네임 입력 필드 (중복확인 버튼 포함) - Figma ProfileView 기준, 닉네임만 사용
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 10) {
                    ProfileTextField(
                        text: $vm.nickname,
                        placeholder: "닉네임 (한글 7자 이내 영문 10자 이내)",
                        textColorName: "25-Text",
                        placeholderColorName: "45-Text",
                        backgroundColorName: "background"
                    )
                    .overlay(alignment: .trailing) {
                        if vm.nicknameCheckState != .idle {
                            TrailingStatusIcon(state: convertToEmailCheckState(vm.nicknameCheckState))
                                .padding(.trailing, 12)
                        }
                    }
                    .onChange(of: vm.nickname) { _, _ in
                        // 닉네임이 변경되면 중복확인 결과 무효화
                        if vm.nicknameCheckState != .idle {
                            vm.nicknameCheckState = .idle
                        }
                        vm.validateNickname()
                    }
                    
                    Button {
                        Task { await vm.checkNicknameDuplicate() }
                    } label: {
                        Text("중복 확인")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color("100"))
                            .frame(width: 84, height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(vm.nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color("85") : Color("PrimaryColor-Varient65"))
                            )
                    }
                    .buttonStyle(.plain)
                    // 비밀번호 재설정 화면과 동일하게, 색은 유지하고 터치만 막기
                    .allowsHitTesting(vm.nicknameCheckState != .checking && vm.isNicknameValid)
                }
            }
            .padding(.bottom, 8)

            // 에러 메시지
            if let errorMessage = vm.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12))
                    .foregroundStyle(Color("StatusRed"))
                    .padding(.bottom, 8)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            
            // 저장 버튼
            Button {
                // 최종 회원가입(`/api/users`) 호출
                vm.completeSignUp()
            } label: {
                HStack {
                    if vm.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color("100")))
                    } else {
                        Text("가입 완료하기")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color("100"))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
            }
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(vm.canSaveProfile ? Color("PrimaryColor-Varient65") : Color("85"))
            )
            .allowsHitTesting(vm.canSaveProfile && !vm.isLoading)
            .padding(.top, 4)
        }
        .animation(.default, value: vm.errorMessage)
    }
}

#Preview("ProfileFormSection - Empty") {
    ProfileFormSectionPreviewWrapper()
        .padding()
        .background(Color("background"))
}

private struct ProfileFormSectionPreviewWrapper: View {
    @StateObject private var vm = ProfileViewModel()
    
    var body: some View {
        ProfileFormSection(vm: vm)
    }
}

// Helper function to convert NicknameCheckState to EmailCheckState for TrailingStatusIcon
private func convertToEmailCheckState(_ state: ProfileViewModel.NicknameCheckState) -> SignUpViewModel.EmailCheckState {
    switch state {
    case .idle:
        return .idle
    case .checking:
        return .checking
    case .available:
        return .available
    case .duplicated:
        return .duplicated
    case .invalidFormat:
        return .invalidFormat
    }
}
