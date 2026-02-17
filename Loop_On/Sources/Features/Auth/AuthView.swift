//
//  AuthView.swift
//  Loop_On
//
//  Created by 이경민 on 12/31/25.
//

import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()

    @Environment(NavigationRouter.self) private var router
    @Environment(SessionStore.self) private var session

    @State private var isPasswordVisible: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                AuthHeader(
                    logoImageName: "Logo",
                    tagline: "2박 3일 여정을 시작해볼까요?\nLOOP 모드를 켜주세요"
                )
                .padding(.top, 60)

                VStack(spacing: 4) {
                    EmailLoginSection(
                        email: $viewModel.email,
                        password: $viewModel.password,
                        isPasswordVisible: $isPasswordVisible,
                        helperText: viewModel.errorMessage,
                        onLoginTapped: {
                            print("ROUTER DEBUG: login 함수 호출 직전")
                            viewModel.login()
                        },
                        onFindTapped: {
                            router.push(.auth(.findPassword))
                        },
                        onSignUpTapped: {
                            router.push(.auth(.signUp))   // 회원가입 이동
                        }
                    )

                    SocialLoginSection(
                        onKakaoTapped: { viewModel.loginWithKakao() },
                        onGoogleTapped: { /* TODO */ },
                        onAppleSuccess: { viewModel.loginWithApple(credential: $0) },
                        onAppleFailure: { viewModel.handleAppleLoginFailure($0) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .background(Color("background"))
        .safeAreaInset(edge: .bottom) {
                TermsFooter(
                    text: "계속 진행하면 이용 약관에 동의하고, 개인정보 처리방침을 확인했음을 인정하게 됩니다."
                )
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)   // 홈 인디케이터 위 여유
                .background(Color("background"))
            }
//        .onChange(of: viewModel.isLoggedIn) { _, loggedIn in
//            guard loggedIn else { return }
//
//            // 이력 저장
//            session.markLoggedIn()
//
//            // 탭바 루트로 복귀
//            router.reset()
//        }
        .onChange(of: viewModel.isLoggedIn) { _, loggedIn in
            guard loggedIn else { return }
            session.markLoggedIn()
            // 로그인 직후 화면 분기는 RootView에서 journeys/current 조회 결과로 결정
            router.reset()
        }
    }
}

#Preview("AuthView - Wrapped") {
    AuthPreviewContainer()
}

private struct AuthPreviewContainer: View {
    @State private var router = NavigationRouter()
    @State private var session = SessionStore()
    @State private var flowStore = SignUpFlowStore()

    var body: some View {
        NavigationStack(path: $router.path) {
            AuthView()
                .environment(router)
                .environment(session)
                .environment(flowStore)
                .navigationDestination(for: Route.self) { route in
                    if case .auth(.signUp) = route {
                        SignUpView()
                            .environment(router)
                            .environment(session)
                            .environment(flowStore)
                    }
                }
        }
    }
}
