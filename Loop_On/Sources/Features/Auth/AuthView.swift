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
                        onKakaoTapped: { /* TODO */ },
                        onGoogleTapped: { /* TODO */ },
                        onAppleSuccess: { _ in /* TODO */ },
                        onAppleFailure: { _ in /* TODO */ }
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
        .onChange(of: viewModel.isLoggedIn) { _, loggedIn in
            guard loggedIn else { return }

            // 이력 저장
            session.markLoggedIn()

            // Home으로 이동
            router.reset()
            router.push(.app(.home))
        }
    }
}

#Preview("AuthView - Wrapped") {
    AuthPreviewContainer()
}

private struct AuthPreviewContainer: View {
    @State private var router = NavigationRouter()
    @State private var session = SessionStore()

    var body: some View {
        NavigationStack(path: $router.path) {
            AuthView()
                .environment(router)
                .environment(session)
                .navigationDestination(for: Route.self) { route in
                    if case .auth(.signUp) = route {
                        SignUpView()
                            .environment(router)
                            .environment(session)
                    }
                }
        }
    }
}


//struct AuthView: View {
//    @StateObject private var viewModel = AuthViewModel()
//
//    var body: some View {
//        VStack(spacing: 20) {
//            TextField("이메일", text: $viewModel.email)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//
//            SecureField("비밀번호", text: $viewModel.password)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//
//            Button("로그인") {
//                viewModel.login()
//            }
//
//            if let error = viewModel.errorMessage {
//                Text(error)
//                    .foregroundColor(.red)
//            }
//
//            if viewModel.isLoggedIn {
//                Text("로그인 성공 🎉")
//                    .foregroundColor(.green)
//            }
//        }
//        .padding()
//    }
//}
