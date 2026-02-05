//
//  AuthAPI.swift
//  Loop_On
//
//  Created by 이경민 on 12/31/25.
//

import Moya
import Foundation

/// Apple 로그인 시 서버로 전달할 요청 바디.
/// - identityToken: Apple이 내려주는 JWT(문자열). 서버에서 검증용으로 사용.
/// - authorizationCode: 서버에서 refresh token 교환 시 활용 가능. (옵션)
/// - userIdentifier: Apple 고유 사용자 ID.
/// - email, firstName, lastName: 첫 로그인에서만 내려올 수 있음.
struct AppleLoginRequest: Encodable {
    let identityToken: String
    let authorizationCode: String?
    let userIdentifier: String
    let email: String?
    let firstName: String?
    let lastName: String?
}

enum AuthAPI {
    case login(email: String, password: String)
    /// Apple 로그인 - identityToken(JWT) 등 전달.
    case appleLogin(request: AppleLoginRequest)
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
        case .appleLogin:
            return "/auth/apple"
        case .signUp:
            return "/api/users"
        case .logout:
            return "/auth/logout"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login, .appleLogin, .signUp: return .post
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
        case let .appleLogin(request):
            return .requestJSONEncodable(request)
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
