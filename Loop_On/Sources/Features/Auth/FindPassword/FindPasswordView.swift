//
//  FindPasswordView.swift
//  Loop_On
//
//  Created by Auto on 1/14/26.
//

import SwiftUI

struct FindPasswordView: View {
    @StateObject private var vm = FindPasswordViewModel()
    @Environment(NavigationRouter.self) private var router
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 이메일 인증 섹션
                VStack(alignment: .leading, spacing: 16) {
                    // 안내 텍스트
                    Text("이메일을 통해 본인인증을 진행해주세요.")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.primary)
                    
                    FindPasswordEmailVerificationSection(vm: vm)
                }
                
                // "새로운 비밀번호를 입력해주세요." 텍스트 - 첫 번째 헬퍼 텍스트와 큰 간격
                Text("새로운 비밀번호를 입력해주세요.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.primary)
                    .padding(.top, 24) // 첫 번째 헬퍼 텍스트와의 간격 (Figma: 24px)
                    .padding(.bottom, 16) // 비밀번호 입력 필드와의 간격 (Figma: 16px)
                
                // 새 비밀번호 섹션
                FindPasswordNewPasswordSection(vm: vm)
                    .padding(.bottom, 12) // 헬퍼 텍스트와 버튼 사이 간격 (Figma: 12px)
                
                // 비밀번호 재설정 버튼
                Button(action: {
                    vm.resetPassword()
                }) {
                    HStack {
                        if vm.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color("100")))
                        } else {
                            Text("비밀번호 재설정")
                                .font(.system(size: 15, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .buttonStyle(.plain)
                // 인증요청/확인 버튼과 동일하게 항상 그레이스케일 100 텍스트 유지
                .foregroundStyle(Color("100"))
                .background(vm.canSubmitPasswordReset ? Color("PrimaryColor55") : Color("85"))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                // 시스템 disabled 스타일 대신 hitTest로만 비활성화 처리하여 색상 변화 방지
                .allowsHitTesting(vm.canSubmitPasswordReset)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("비밀번호 재설정")
                    .font(.system(size: 20, weight: .bold))
            }
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 0) {
                    Button(action: {
                        router.pop()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.primary)
                    }
                    Spacer()
                }
                .frame(width: 44) // 네비게이션 바 기본 너비
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .background(Color("background"))
        .onChange(of: vm.isPasswordResetComplete) { _, isComplete in
            if isComplete {
                // 비밀번호 재설정 완료
                // TODO: 성공 화면으로 이동하거나 토스트 메시지 표시
                router.pop()
            }
        }
    }
}

#Preview("FindPasswordView - Wrapped") {
    FindPasswordPreviewContainer()
}

private struct FindPasswordPreviewContainer: View {
    @State private var router = NavigationRouter()
    @State private var session = SessionStore()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            FindPasswordView()
                .environment(router)
                .environment(session)
        }
    }
}
