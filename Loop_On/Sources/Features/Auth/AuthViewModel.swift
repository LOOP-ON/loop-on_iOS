//
//  AuthViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 12/31/25.
//

import Foundation

// 서버 응답 모델
struct LoginResponse: Decodable {
    let token: String
    let userId: Int
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
                // Body로 받은 accessToken만 키체인에 저장
                KeychainService.shared.saveToken(response.token)
                
                // refreshToken은 iOS 시스템 쿠키 저장소에 자동으로 담김
                self?.isLoggedIn = true
            case .failure(let error):
                self?.errorMessage = "이메일 또는 비밀번호가 일치하지 않습니다."
            }
        }
    }
}
