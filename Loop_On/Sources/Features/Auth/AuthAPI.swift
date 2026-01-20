//
//  AuthAPI.swift
//  Loop_On
//
//  Created by 이경민 on 12/31/25.
//

import Moya
import Foundation
import UIKit

enum AuthAPI {
    case login(email: String, password: String)
    case signUp(request: SignUpRequest, profileImage: UIImage?)
    // 로그아웃
    // 토큰 재발
}

extension AuthAPI: TargetType {
    var baseURL: URL { URL(string: API.baseURL)! }

    var path: String {
        switch self {
        case .login: return "/auth/login"
        case .signUp: return "/auth/signup"
        }
    }

    var method: Moya.Method {
        switch self {
            case .login, .signUp: return .post
        }
    }

    var task: Task {
        switch self {
        case let .login(email, password):
            return .requestParameters(
                parameters: ["email": email, "password": password],
                encoding: JSONEncoding.default
            )
        
        case let .signUp(request, image):
            // 사진이 포함되므로 MultipartFormData로 미리 준비 가능.
            // 명세서가 나오면 필드 이름(name)만 수정.
            var formData: [MultipartFormData] = []
            
            // 텍스트 데이터 추가
            if let jsonData = try? JSONEncoder().encode(request) {
                formData.append(MultipartFormData(provider: .data(jsonData), name: "signupData", mimeType: "application/json"))
            }
                
            // 이미지 데이터 추가
            if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
                formData.append(MultipartFormData(provider: .data(imageData), name: "profileImage", fileName: "profile.jpg", mimeType: "image/jpeg"))
            }
            return .uploadMultipart(formData)
        }
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}
