//
//  ProfileAPI.swift
//  Loop_On
//
//  Created by Auto on 1/14/26.
//

import Moya
import Foundation

enum ProfileAPI {
    case createProfile(profile: ProfileDTO)
    case updateProfile(profile: ProfileDTO)
    case getProfile
    case getMe
}

extension ProfileAPI: TargetType {
    var baseURL: URL { URL(string: API.baseURL)! }
    
    var path: String {
        switch self {
        case .createProfile, .updateProfile, .getProfile:
            return "/profile"
        case .getMe:
            return "/api/users/me"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createProfile:
            return .post
        case .updateProfile:
            return .put
        case .getProfile:
            return .get
        case .getMe:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case let .createProfile(profile), let .updateProfile(profile):
            return .requestJSONEncodable(profile)
        case .getProfile:
            return .requestPlain
        case .getMe:
            return .requestParameters(
                parameters: ["page": 0, "size": 10, "sort": "createdAt,desc"],
                encoding: URLEncoding.queryString
            )
        }
    }
    
    var headers: [String: String]? {
        var header = ["Content-Type": "application/json"]
            
        if let token = KeychainService.shared.loadToken() {
            header["Authorization"] = "Bearer \(token)"
            print("DEBUG: ProfileAPI - 인증 헤더 추가됨")
        } else {
            print("DEBUG: ProfileAPI - 헤더에 넣을 토큰이 없습니다.")
        }
            
        return header
    }
}
