//
//  socialLoginSection.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import SwiftUI
import AuthenticationServices

struct SocialLoginSection: View {
    let onKakaoTapped: () -> Void
    let onGoogleTapped: () -> Void
    let onAppleSuccess: (ASAuthorizationAppleIDCredential) -> Void
    let onAppleFailure: (Error) -> Void
    
    var body: some View {
        VStack(spacing: 8){
            OrDividerView(text: "또는")
                .padding(.bottom, 8)
            
            SocialLoginButton(
                title: "카카오 계정으로 로그인",
                style: .kakao,
                icon: .system(name: "message.fill"),
                action: onKakaoTapped
            )
            
            SocialLoginButton(
                title: "구글 계정으로 로그인",
                style: .google,
                icon: .asset(name: "googleLogo"),
                action: onGoogleTapped
            )
            
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                case .success(let auth):
                    if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                        onAppleSuccess(credential)
                    }
                case .failure(let error):
                    onAppleFailure(error)
                }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

#Preview("SocialLoginSectionView - Light") {
    SocialLoginSection(
        onKakaoTapped: { print("Kakao tapped") },
        onGoogleTapped: { print("Google tapped") },
        onAppleSuccess: { _ in print("Apple success") },
        onAppleFailure: { error in print("Apple failure: \(error.localizedDescription)") }
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("SocialLoginSectionView - Dark") {
    SocialLoginSection(
        onKakaoTapped: { print("Kakao tapped") },
        onGoogleTapped: { print("Google tapped") },
        onAppleSuccess: { _ in print("Apple success") },
        onAppleFailure: { error in print("Apple failure: \(error.localizedDescription)") }
    )
    .padding()
    .background(Color(.systemGroupedBackground))
    .preferredColorScheme(.dark)
}
