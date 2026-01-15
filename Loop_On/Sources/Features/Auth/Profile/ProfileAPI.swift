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
}

extension ProfileAPI: TargetType {
    var baseURL: URL { URL(string: API.baseURL)! }
    
    var path: String {
        switch self {
        case .createProfile, .updateProfile, .getProfile:
            return "/profile"
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
        }
    }
    
    var task: Task {
        switch self {
        case let .createProfile(profile), let .updateProfile(profile):
            return .requestJSONEncodable(profile)
        case .getProfile:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}
