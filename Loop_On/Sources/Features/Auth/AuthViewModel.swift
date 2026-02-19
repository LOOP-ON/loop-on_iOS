//
//  AuthViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 12/31/25.
//

import Foundation
import UIKit
import AuthenticationServices
import KakaoSDKAuth
import KakaoSDKUser



// 실제 로그인 데이터 모델
struct LoginData: Decodable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "accessToken"
        case accessTokenSnake = "access_token"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        if let token = try? c.decode(String.self, forKey: .accessToken) {
            accessToken = token
        } else {
            accessToken = try c.decode(String.self, forKey: .accessTokenSnake)
        }
    }
}

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
        print("DEBUG: login() 함수 진입 - email: \(email)")
            
        networkManager.request(
            target: .login(email: email, password: password),
            decodingType: LoginData.self
        ) { [weak self] result in
            switch result {
            case .success(let loginData):
                KeychainService.shared.saveToken(loginData.accessToken)
                // 일반 이메일 로그인이므로 소셜 정보 삭제
                UserDefaults.standard.removeObject(forKey: "loginProvider")
                self?.isLoggedIn = true
                print("로그인 성공!")
                    
            case .failure(let error):
                print("로그인 실패 에러: \(error)")
                // 요청하신 대로 에러 메시지 고정
                self?.errorMessage = "비밀번호가 일치하지 않습니다."
            }
        }
    }

    func loginWithKakao() {
        print("✅ Kakao login start")
        if UserApi.isKakaoTalkLoginAvailable() {
            print("✅ KakaoTalk app login available")
            UserApi.shared.loginWithKakaoTalk { [weak self] token, error in
                self?.handleKakaoLoginResult(token: token, error: error)
            }
        } else {
            print("✅ Kakao account login fallback")
            UserApi.shared.loginWithKakaoAccount { [weak self] token, error in
                self?.handleKakaoLoginResult(token: token, error: error)
            }
        }
    }

    private func handleKakaoLoginResult(token: OAuthToken?, error: Error?) {
        Task { @MainActor in
            print("✅ handleKakaoLoginResult started")
            if let error {
                errorMessage = "카카오 로그인에 실패했습니다."
                print("Kakao login error: \(error.localizedDescription)")
                return
            }

            guard let accessToken = token?.accessToken else {
                errorMessage = "카카오 로그인 토큰을 가져오지 못했습니다."
                return
            }

            print("✅ Kakao token received")
            print("KAKAO accessToken:", accessToken)
            ensureKakaoScopes { [weak self] scopedToken in
                guard let self else { return }
                let backendToken = scopedToken ?? accessToken
                // print("✅ Backend request: /api/auth/login/social")
                // print("✅ Backend body: {\"provider\":\"KAKAO\",\"accessToken\":\"\(backendToken)\"}")
                self.networkManager.request(
                    target: .socialLogin(request: SocialLoginRequest(provider: "KAKAO", accessToken: backendToken)),
                    decodingType: LoginData.self
                ) { [weak self] result in
                    guard let self else { return }
                    Task { @MainActor in
                        switch result {
                        case .success(let loginData):
                            // print("✅ Backend response: \(loginData)")
                            // print("isMainThread:", Thread.isMainThread)
                            DispatchQueue.main.async {
                                KeychainService.shared.saveToken(loginData.accessToken)
                                UserDefaults.standard.set("KAKAO", forKey: "loginProvider")
                                self.isLoggedIn = true
                                print("✅ isLoggedIn set to true")
                            }
                        case .failure(let error):
                            print("❌ Kakao socialLogin failed:", error)
                            self.errorMessage = "카카오 로그인에 실패했습니다."
                        }
                    }
                }
            }
        }
    }

    private func ensureKakaoScopes(completion: @escaping (String?) -> Void) {
        let requiredScopes = ["profile_nickname", "account_email", "profile_image"]
        UserApi.shared.me { [weak self] user, error in
            if let error {
                print("Kakao user info error: \(error.localizedDescription)")
            }

            let hasNickname = !(user?.kakaoAccount?.profile?.nickname?.isEmpty ?? true)
            let hasEmail = !(user?.kakaoAccount?.email?.isEmpty ?? true)
            let hasProfileImage = !(user?.kakaoAccount?.profile?.profileImageUrl?.absoluteString.isEmpty ?? true)

            if hasNickname && hasEmail && hasProfileImage {
                completion(nil)
                return
            }

            // 동의 항목 부족 시 추가 동의 요청
            UserApi.shared.loginWithKakaoAccount(scopes: requiredScopes) { token, error in
                if let error {
                    Task { @MainActor in
                        self?.errorMessage = "카카오 동의 항목을 확인해 주세요."
                    }
                    print("Kakao scope consent error: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(token?.accessToken)
            }
        }
    }

    /// Apple Sign In 성공 시 호출. credential의 Authorization Code를 서버에 전달.
    /// 시뮬레이터에서는 authorizationCode가 nil인 경우가 있어, identityToken을 폴백으로 사용.
    func loginWithApple(credential: ASAuthorizationAppleIDCredential) {
        print("[Apple 로그인] loginWithApple 호출됨")

        let accessToken: String
        if let codeData = credential.authorizationCode,
           let code = String(data: codeData, encoding: .utf8) {
            accessToken = code
            print("[Apple 로그인] authorizationCode 사용")
        } else if let tokenData = credential.identityToken,
                  let token = String(data: tokenData, encoding: .utf8) {
            // 시뮬레이터 등에서 authorizationCode가 nil일 때 폴백 (서버가 identityToken도 받을 수 있어야 함)
            accessToken = token
            print("[Apple 로그인] identityToken 폴백 사용")
        } else {
            print("[Apple 로그인] authorizationCode, identityToken 둘 다 nil")
            errorMessage = "Apple 로그인 정보를 가져올 수 없습니다."
            return
        }

        // Swagger 테스트용: accessToken을 클립보드에 복사 (개발 완료 후 제거)
        UIPasteboard.general.string = accessToken
        print("[Swagger 테스트] Apple token 클립보드 복사됨. Swagger accessToken에 Cmd+V 붙여넣기")

        let request = SocialLoginRequest(provider: "APPLE", accessToken: accessToken)

        networkManager.request(
            target: .socialLogin(request: request),
            decodingType: LoginData.self
        ) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let loginData):
                    KeychainService.shared.saveToken(loginData.accessToken)
                    UserDefaults.standard.set("APPLE", forKey: "loginProvider")
                    self?.isLoggedIn = true
                    print("✅ [Apple] 로그인 성공, isLoggedIn = true")
                case .failure(let error):
                    print("❌ [Apple] 로그인 실패: \(error)")
                    self?.errorMessage = "Apple 로그인에 실패했습니다. 잠시 후 다시 시도해 주세요."
                }
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
