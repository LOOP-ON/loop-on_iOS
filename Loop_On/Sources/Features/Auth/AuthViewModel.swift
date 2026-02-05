//
//  AuthViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 12/31/25.
//

import Foundation
import AuthenticationServices

/// 로그인 성공 시 서버 응답 모델. accessToken은 키체인에 보관됩니다.
/// 서버에서 "accessToken" 또는 "token" 키로 내려줄 수 있도록 CodingKeys 지원.
struct LoginResponse: Decodable {
    let accessToken: String
    let userId: Int

    enum CodingKeys: String, CodingKey {
        case accessToken
        case token
        case userId
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        // 서버가 "accessToken" 또는 "token" 중 하나로 보낼 수 있음
        if let token = try? c.decode(String.self, forKey: .accessToken) {
            accessToken = token
        } else {
            accessToken = try c.decode(String.self, forKey: .token)
        }
        userId = try c.decode(Int.self, forKey: .userId)
    }
}

@MainActor
final class AuthViewModel: ObservableObject {
//    @Published var email: String = ""
//    @Published var password: String = ""
//    @Published var errorMessage: String?
//    @Published var isLoggedIn: Bool = false
    @Published var email: String = "" {
        didSet { clearError() }
    }
    @Published var password: String = "" {
        didSet { clearError() }
    }
    @Published var errorMessage: String?
    @Published var isLoggedIn: Bool = false

    private let networkManager = DefaultNetworkManager<AuthAPI>()

    private func clearError() {
        if errorMessage != nil { errorMessage = nil }
    }

    func login() {
        networkManager.request(
            target: .login(email: email, password: password),
            decodingType: LoginResponse.self
        ) { [weak self] result in
            switch result {
            case .success(let response):
                // Body로 받은 accessToken을 키체인에 저장
                KeychainService.shared.saveToken(response.accessToken)
                
                // refreshToken은 iOS 시스템 쿠키 저장소에 자동으로 담김
                self?.isLoggedIn = true
            case .failure(let error):
                self?.errorMessage = "이메일 또는 비밀번호가 일치하지 않습니다."
            }
        }
    }

    /// Apple Sign In 성공 시 호출. credential에서 토큰을 추출해 서버 로그인 수행.
    func loginWithApple(credential: ASAuthorizationAppleIDCredential) {
        guard let identityTokenData = credential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8) else {
            errorMessage = "Apple 로그인 정보를 가져올 수 없습니다."
            return
        }

        let authorizationCode = credential.authorizationCode.flatMap { String(data: $0, encoding: .utf8) }
        let fullName = credential.fullName

        let request = AppleLoginRequest(
            identityToken: identityToken,
            authorizationCode: authorizationCode,
            userIdentifier: credential.user,
            email: credential.email,
            firstName: fullName?.givenName,
            lastName: fullName?.familyName
        )

        networkManager.request(
            target: .appleLogin(request: request),
            decodingType: LoginResponse.self
        ) { [weak self] result in
            switch result {
            case .success(let response):
                KeychainService.shared.saveToken(response.accessToken)
                self?.isLoggedIn = true
            case .failure:
                self?.errorMessage = "Apple 로그인에 실패했습니다. 잠시 후 다시 시도해 주세요."
            }
        }
    }

    /// Apple Sign In 실패 콜백에서 호출.
    func handleAppleLoginFailure(_ error: Error) {
        let nsError = error as NSError
        if nsError.domain == ASAuthorizationError.errorDomain,
           nsError.code == ASAuthorizationError.canceled.rawValue {
            // 사용자가 취소한 경우 에러 메시지 표시하지 않음
            errorMessage = nil
            return
        }
        errorMessage = "Apple 로그인에 실패했습니다."
    }
}
