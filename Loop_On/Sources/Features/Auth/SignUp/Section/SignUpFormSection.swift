//
//  SignUpFormSection.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import SwiftUI

struct SignUpFormSection: View {
    @ObservedObject var vm: SignUpViewModel
    @State private var isPwVisible = false
    @State private var isPwConfirmVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                AuthTextField(
                    text: $vm.email,
                    placeholder: "이메일",
                    textColorName: "25-Text",
                    placeholderColorName: "45-Text",
                    backgroundColorName: "background",
                    height: 40,
                    keyboard: .emailAddress
                )
                .overlay(alignment: .trailing) {
                    TrailingStatusIcon(state: vm.emailCheckState)
                        .padding(.trailing, 12)
                }

                Button {
                    Task { await vm.checkEmailDuplicate() }
                } label: {
                    Text("중복 확인")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 84, height: 40)
                        .background(Color("PrimaryColor-Varient75"))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .tint(Color("PrimaryColor-Varient75"))
                .foregroundStyle(Color("100"))
            }

            AuthSecureField(
                text: $vm.password,
                placeholder: "비밀번호 (영문, 숫자 포함 8~16자)",
                isVisible: $isPwVisible,
                textColorName: "25-Text",
                placeholderColorName: "45-Text",
                backgroundColorName: "background",
                height: 40
            )

            AuthSecureField(
                text: $vm.passwordConfirm,
                placeholder: "비밀번호 재입력",
                isVisible: $isPwConfirmVisible,
                textColorName: "25-Text",
                placeholderColorName: "45-Text",
                backgroundColorName: "background",
                height: 40
            )

            Text(vm.helperMessage ?? "")
                .font(.footnote)
                .foregroundStyle(vm.helperMessage == nil ? Color.clear : Color.red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 10) // 자리 고정 (레이아웃 안 흔들림)


            Button {
                // TODO: 다음 단계(프로필/추가정보)로 이동
            } label: {
                Text("다음으로")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color("85"))
            .foregroundStyle(Color("100"))
            .disabled(!vm.canGoNext)
            .opacity(vm.canGoNext ? 1 : 0.7)
        }
        .padding(16)
        .background(Color("100"))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview("SignUpFormSection - Empty") {
    SignUpFormSectionPreviewWrapper(preset: .empty)
        .padding()
        .background(Color(.systemGroupedBackground))
}

#Preview("SignUpFormSection - Available") {
    SignUpFormSectionPreviewWrapper(preset: .available)
        .padding()
        .background(Color(.systemGroupedBackground))
}

#Preview("SignUpFormSection - Duplicated") {
    SignUpFormSectionPreviewWrapper(preset: .duplicated)
        .padding()
        .background(Color(.systemGroupedBackground))
}

private struct SignUpFormSectionPreviewWrapper: View {
    enum Preset { case empty, available, duplicated }

    @StateObject private var vm = SignUpViewModel()
    let preset: Preset

    var body: some View {
        SignUpFormSection(vm: vm)
            .onAppear {
                // 프리뷰에서 상태를 빠르게 확인하기 위한 더미 값
                switch preset {
                case .empty:
                    vm.email = ""
                    vm.password = ""
                    vm.passwordConfirm = ""
                    vm.emailCheckState = .idle

                case .available:
                    vm.email = "test@loopon.com"
                    vm.password = "abc12345"
                    vm.passwordConfirm = "abc12345"
                    vm.emailCheckState = .available

                case .duplicated:
                    vm.email = "used@loopon.com"
                    vm.password = "abc12345"
                    vm.passwordConfirm = "abc12345"
                    vm.emailCheckState = .duplicated
                }
            }
    }
}
