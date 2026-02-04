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
    /// 회원가입 - UserSignUpRequest (`/api/users`)
    /// 현재 단계에서는 이메일/비밀번호/비밀번호 확인만 전송하고,
    /// 이름/닉네임/생년월일은 프로필 API에서 별도 관리한다.
    case signUp(request: SignUpRequest)
    /// 로그아웃. 서버 연동 후 엔드포인트 연결 시 사용. 로그아웃 시 KeychainService.deleteToken()은 SessionStore에서 호출됨.
    case logout
    // 토큰 재발 (서버 명세 후 추가)
}

extension AuthAPI: TargetType {
    var baseURL: URL { URL(string: API.baseURL)! }

    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .signUp:
            return "/api/users"
        case .logout:
            return "/auth/logout"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login, .signUp: return .post
        case .logout: return .post
        }
    }

    var task: Task {
        switch self {
        case let .login(email, password):
            return .requestParameters(
                parameters: ["email": email, "password": password],
                encoding: JSONEncoding.default
            )
        case let .signUp(request):
            return .requestJSONEncodable(request)
        case .logout:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}
