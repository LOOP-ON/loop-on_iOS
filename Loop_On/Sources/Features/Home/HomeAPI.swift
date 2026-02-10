//
//  HomeAPI.swift
//  Loop_On
//
//  Created by 이경민 on 2/10/26.
//

import Foundation
import Moya

enum HomeAPI {
    case fetchCurrentJourney
}

extension HomeAPI: TargetType {
    var baseURL: URL {
        return URL(string: API.baseURL)!
    }
    
    var path: String {
        switch self {
        case .fetchCurrentJourney:
            return "/api/journeys/current"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String: String]? {
        // TODO: Keychain에서 실제 토큰을 가져오도록 수정 필요
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "accessToken") ?? "")"
        ]
    }
}
