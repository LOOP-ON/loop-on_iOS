//
//  AuthViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 12/31/25.
//

import Foundation

struct BaseResponse<T: Decodable>: Decodable {
    let result: String
    let code: String
    let message: String
    let data: T?
}

// 실제 로그인 데이터 모델
struct LoginData: Decodable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "accessToken"
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
                self?.isLoggedIn = true
                print("로그인 성공!")
                    
            case .failure(let error):
                print("로그인 실패 에러: \(error)")
                // 요청하신 대로 에러 메시지 고정
                self?.errorMessage = "비밀번호가 일치하지 않습니다."
            }
        }
    }
}
