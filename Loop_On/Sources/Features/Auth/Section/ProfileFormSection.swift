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
            // 이름 입력 필드
            ProfileTextField(
                text: $vm.name,
                placeholder: "이름",
                textColorName: "25-Text",
                placeholderColorName: "45-Text",
                backgroundColorName: "background"
            )
            .onChange(of: vm.name) { _, _ in
                vm.validateName()
            }
            .padding(.bottom, 8)
            
            // 닉네임 입력 필드 (중복확인 버튼 포함)
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
                    .disabled(vm.nicknameCheckState == .checking || !vm.isNicknameValid)
                }
            }
            .padding(.bottom, 8)
            
            // 생년월일 입력 필드
            VStack(alignment: .leading, spacing: 4) {
                ProfileTextField(
                    text: $vm.birthday,
                    placeholder: "생년월일 (YYYYMMDD)",
                    textColorName: "25-Text",
                    placeholderColorName: "45-Text",
                    backgroundColorName: "background",
                    keyboard: .numberPad
                )
                .overlay(alignment: .trailing) {
                    if vm.isBirthdayValid {
                        TrailingStatusIcon(state: .available)
                            .padding(.trailing, 12)
                    }
                }
                .onChange(of: vm.birthday) { _, _ in
                    // 숫자만 입력되도록 제한
                    vm.birthday = String(vm.birthday.prefix(8))
                    vm.validateBirthday()
                }
                
                // Helper Text 공간 항상 확보
                Text(vm.birthdayHelperText ?? "")
                    .font(.system(size: 12))
                    .foregroundStyle(vm.birthdayHelperText == nil ? Color.clear : Color("StatusRed"))
                    .frame(height: 16, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // 에러 메시지
            if let errorMessage = vm.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12))
                    .foregroundStyle(Color("StatusRed"))
                    .padding(.top, 4)
            }
            
            // 저장 버튼
            Button {
                vm.saveProfile()
            } label: {
                HStack {
                    if vm.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color("100")))
                    } else {
                        Text("3일 여정 시작하기")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color("100"))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
            }
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(vm.canSaveProfile ? Color("PrimaryColor55") : Color("85"))
            )
            .disabled(!vm.canSaveProfile || vm.isLoading)
            .opacity(vm.canSaveProfile && !vm.isLoading ? 1 : 0.7)
            .padding(.top, 8)
        }
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
