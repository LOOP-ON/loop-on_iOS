//
//  AuthAPI.swift
//  Loop_On
//
//  Created by 이경민 on 12/31/25.
//

import Moya
import Foundation

/// 소셜 로그인 시 서버로 전달할 요청 바디. (`POST /api/auth/login/social`)
/// - provider: "KAKAO" 또는 "APPLE"
/// - accessToken: KAKAO는 카카오 Access Token, APPLE은 애플 Authorization Code
struct SocialLoginRequest: Encodable {
    let provider: String
    let accessToken: String
}

enum AuthAPI {
    case login(email: String, password: String)
    /// 소셜 로그인 (카카오/애플) - provider와 accessToken 전달. `/api/auth/login/social`
    case socialLogin(request: SocialLoginRequest)
    /// 회원가입 - UserSignUpRequest (`/api/users`)
    /// 현재 단계에서는 이메일/비밀번호/비밀번호 확인만 전송하고,
    /// 이름/닉네임/생년월일은 프로필 API에서 별도 관리한다.
    case signUp(request: SignUpRequest)
    /// 이메일 중복 확인 (`/api/users/check-email`)
    case checkEmail(email: String)
    /// 닉네임 중복 확인 (`/api/users/check-nickname`)
    case checkNickname(nickname: String)
    /// 프로필 이미지 업로드 (`/api/users/upload-profile-image`)
    /// - NOTE: multipart field name은 서버 명세에 따라 조정 필요 (현재 "file")
    case uploadProfileImage(data: Data, fileName: String, mimeType: String)
    /// 로그아웃. 서버 연동 후 엔드포인트 연결 시 사용. 로그아웃 시 KeychainService.deleteToken()은 SessionStore에서 호출됨.
    case logout
    // 토큰 재발 (서버 명세 후 추가)
}

extension AuthAPI: TargetType {
    var baseURL: URL {
        guard let url = URL(string: API.baseURL) else {
            fatalError("Invalid API.baseURL: \(API.baseURL)")
        }
        return url
    }

    var path: String {
        switch self {
        case .login:
            return "/api/auth/login"
        case .socialLogin:
            return "/api/auth/login/social"
        case .signUp:
            return "/api/users"
        case .checkEmail:
            return "/api/users/check-email"
        case .checkNickname:
            return "/api/users/check-nickname"
        case .uploadProfileImage:
            return "/api/users/upload-profile-image"
        case .logout:
            return "/auth/logout"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login, .socialLogin, .signUp, .checkEmail, .checkNickname, .uploadProfileImage:
            return .post
        case .logout:
            return .post
        }
    }

    var task: Task {
        switch self {
        case let .login(email, password):
            return .requestParameters(
                parameters: ["email": email, "password": password],
                encoding: JSONEncoding.default
            )
            
        case let .socialLogin(request):
            return .requestJSONEncodable(request)
            
        case let .signUp(request):
            return .requestJSONEncodable(request)
            
        case let .checkEmail(email):
            return .requestParameters(
                parameters: ["email": email], encoding: URLEncoding.queryString
            )
        
        // 닉네임 중복 확인
        case let .checkNickname(nickname):
            return .requestParameters(
                parameters: ["nickname": nickname],
                encoding: URLEncoding.queryString
            )
            
        case let .uploadProfileImage(data, fileName, mimeType):
            let form = MultipartFormData(
                provider: .data(data),
                name: "file", // 서버 명세에 따라 "image" 등으로 변경될 수 있음
                fileName: fileName,
                mimeType: mimeType
            )
            return .uploadMultipart([form])
            
        case .logout:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        switch self {
        case .uploadProfileImage:
            // Moya가 boundary 포함 Content-Type을 자동으로 설정하도록 비워둠
            return nil
        default:
            return ["Content-Type": "application/json"]
        }
    }
}
