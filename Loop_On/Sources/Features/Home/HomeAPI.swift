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
    case postponeRoutine(journeyId: Int, request: RoutinePostponeRequest)
    case certifyRoutine(progressId: Int, imageData: Data, fileName: String, mimeType: String)
    case continueJourney(journeyId: Int)
}

extension HomeAPI: TargetType {
    var baseURL: URL {
        return URL(string: API.baseURL)!
    }
    
    var path: String {
        switch self {
        case .fetchCurrentJourney:
            return "/api/journeys/current"
        case let .postponeRoutine(journeyId, _):
            return "/api/journeys/\(journeyId)/routines/postpone"
        case let .certifyRoutine(progressId, _, _, _):
            return "/api/routines/\(progressId)/certify"
        case let .continueJourney(journeyId):
            return "/api/journeys/\(journeyId)/continue"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchCurrentJourney:
            return .get
        case .postponeRoutine, .certifyRoutine, .continueJourney:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .fetchCurrentJourney:
            return .requestPlain
        case let .postponeRoutine(_, request):
            return .requestJSONEncodable(request)
        case let .certifyRoutine(_, imageData, fileName, mimeType):
            let form = MultipartFormData(
                provider: .data(imageData),
                name: "image",
                fileName: fileName,
                mimeType: mimeType
            )
            return .uploadMultipart([form])
        case .continueJourney:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        var header: [String: String] = [:]
        switch self {
        case .fetchCurrentJourney, .postponeRoutine, .continueJourney:
            header["Content-Type"] = "application/json"
        case .certifyRoutine:
            // Multipart 경계(boundary)는 Moya가 자동 설정하도록 Content-Type 미설정
            break
        }
        if let token = KeychainService.shared.loadToken(), !token.isEmpty {
            header["Authorization"] = "Bearer \(token)"
        }
        return header
    }
}
