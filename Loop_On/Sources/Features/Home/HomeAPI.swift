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
    case fetchJourneyRecord(journeyId: Int)
    case postponeRoutine(journeyId: Int, request: RoutinePostponeRequest)
    case fetchPostponeReason(progressId: Int)
    case updatePostponeReason(progressId: Int, request: RoutinePostponeReasonUpdateRequest)
    case certifyRoutine(progressId: Int, imageData: Data, fileName: String, mimeType: String)
    case createRoutineRecord(journeyId: Int, request: RoutineRecordRequest)
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
        case let .fetchJourneyRecord(journeyId):
            return "/api/journeys/\(journeyId)/record"
        case let .postponeRoutine(journeyId, _):
            return "/api/journeys/\(journeyId)/routines/postpone"
        case let .fetchPostponeReason(progressId):
            return "/api/routines/\(progressId)/postpone-reason"
        case let .updatePostponeReason(progressId, _):
            return "/api/routines/\(progressId)/postpone-reason"
        case let .certifyRoutine(progressId, _, _, _):
            return "/api/routines/\(progressId)/certify"
        case let .createRoutineRecord(journeyId, _):
            return "/api/routines/\(journeyId)/routine-record"
        case let .continueJourney(journeyId):
            return "/api/journeys/\(journeyId)/continue"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchCurrentJourney, .fetchJourneyRecord, .fetchPostponeReason:
            return .get
        case .updatePostponeReason:
            return .patch
        case .postponeRoutine, .certifyRoutine, .createRoutineRecord, .continueJourney:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .fetchCurrentJourney:
            return .requestPlain
        case .fetchJourneyRecord:
            return .requestPlain
        case let .postponeRoutine(_, request):
            return .requestJSONEncodable(request)
        case .fetchPostponeReason:
            return .requestPlain
        case let .updatePostponeReason(_, request):
            return .requestJSONEncodable(request)
        case let .certifyRoutine(_, imageData, fileName, mimeType):
            let form = MultipartFormData(
                provider: .data(imageData),
                name: "image",
                fileName: fileName,
                mimeType: mimeType
            )
            return .uploadMultipart([form])
        case let .createRoutineRecord(_, request):
            return .requestJSONEncodable(request)
        case .continueJourney:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        var header: [String: String] = [:]
        header["Accept"] = "application/json"
        switch self {
        case .fetchCurrentJourney, .fetchJourneyRecord, .postponeRoutine, .fetchPostponeReason, .updatePostponeReason, .createRoutineRecord, .continueJourney:
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
