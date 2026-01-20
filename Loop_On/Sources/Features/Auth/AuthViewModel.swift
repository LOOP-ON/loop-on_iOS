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

struct SignUpRequest: Codable {
    let email: String
    let password: String
    let name: String
    let nickname: String
    let birthDate: String
}

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var isLoggedIn: Bool = false

    private let networkManager = DefaultNetworkManager<AuthAPI>()

    func login() {
        networkManager.request(
            target: .login(email: email, password: password),
            decodingType: LoginResponse.self
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                print("로그인 성공, 토큰: \(response.token)")
                self.isLoggedIn = true
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                
            }
        }
    }
}
