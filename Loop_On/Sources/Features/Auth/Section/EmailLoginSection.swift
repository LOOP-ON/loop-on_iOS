//
//  emailLoginSection.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import SwiftUI

struct EmailLoginSection: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var isPasswordVisible: Bool
    
    let helperText: String?
    
    let onLoginTapped: () -> Void
    let onFindTapped: () -> Void
    let onSignUpTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("이메일로 로그인")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.primary)
            
            VStack{
                TextField(
                    "",
                    text: $email,
                    prompt: Text("이메일을 입력해주세요")
                        .foregroundStyle(Color("45-Text")) // placeholder 색
                )
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .submitLabel(.next)
                .textFieldStyle(.plain)
                .padding(.horizontal, 14)
                .frame(height: 44)
                .foregroundStyle(Color("45-Text"))       // 입력된 텍스트 색
                .background(Color("95"))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                
                passwordField
                
                // 에러 메시지가 있을 때만 Helper Text 렌더링
                Text(helperText ?? "")
                    .font(.footnote)
                    .foregroundStyle(Color("red"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 5) // 고정 높이를 설정하여 영역 유지
                    .padding(.vertical, 2) // 위아래 적절한 간격 유지
                    .opacity(helperText == nil ? 0 : 1) // 에러가 없으면 숨김 처리
                
                Button(action: onLoginTapped) {
                    Text("로그인")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundStyle(Color(.white))
                        .background(Color("85"))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(!canSubmit)
                .opacity(canSubmit ? 1 : 0.8)
            }
            
            HStack {
                Button("이메일 | 비밀번호 찾기", action: onFindTapped)
                    .font(.footnote)
                    .foregroundStyle(Color("45-Text"))
                
                Spacer()
                
                Button("회원가입", action: onSignUpTapped)
                    .font(.footnote)
                    .foregroundStyle(Color("45-Text"))
            }
            .padding(.top, 6)
        }
        .padding(16)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .animation(.default, value: helperText)
    }
    
    private var passwordField: some View {
        HStack(spacing: 10) {
            Group {
                if isPasswordVisible {
                    TextField(
                        "",
                        text: $password,
                        prompt: Text("비밀번호를 입력해주세요")
                            .foregroundStyle(Color("45-Text"))   // placeholder 색
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .foregroundStyle(Color("25-Text"))           // 입력 텍스트 색
                } else {
                    SecureField(
                        "",
                        text: $password,
                        prompt: Text("비밀번호를 입력해주세요")
                            .foregroundStyle(Color("45-Text"))   // placeholder 색
                    )
                    .foregroundStyle(Color("25-Text"))           // 입력 텍스트 색
                }
            }
            .submitLabel(.done)
            .textFieldStyle(.plain)
            
            Button {
                isPasswordVisible.toggle()
            } label: {
                Image(isPasswordVisible ? "visible" : "invisible")
                    .foregroundStyle(Color(.tertiaryLabel))
            }
            .accessibilityLabel(isPasswordVisible ? "비밀번호 숨기기" : "비밀번호 보기")
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(Color("95"))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}



#Preview("EmailLoginSectionView") {
    EmailLoginSectionPreviewWrapper()
        .padding()
        .background(Color(.systemGroupedBackground))
}

private struct EmailLoginSectionPreviewWrapper: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        EmailLoginSection(
            email: $email,
            password: $password,
            isPasswordVisible: $isPasswordVisible,
            helperText: "Helper Text",
            onLoginTapped: {
                print("로그인 탭")
            },
            onFindTapped: {
                print("찾기 탭")
            },
            onSignUpTapped: {
                print("회원가입 탭")
            }
        )
    }
}

