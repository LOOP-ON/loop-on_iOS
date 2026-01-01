//
//  AuthAPI.swift
//  Loop_On
//
//  Created by 이경민 on 12/31/25.
//

import Moya
import Foundation

enum AuthAPI {
    case login(email: String, password: String)
    // 로그아웃
    // 토큰 재발
}

extension AuthAPI: TargetType {
    var baseURL: URL { URL(string: API.baseURL)! }

    var path: String {
        switch self {
        case .login: return "/auth/login"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login: return .post
        }
    }

    var task: Task {
        switch self {
        case let .login(email, password):
            return .requestParameters(
                parameters: ["email": email, "password": password],
                encoding: JSONEncoding.default
            )
        }
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}
