//
//  OnboardingAPI.swift
//  Loop_On
//
//  Created by 김세은 on 1/22/26.
//

import Foundation
import Moya

enum OnboardingAPI {
    // 여정 목표 생성 (POST /api/journeys/goals)
    case createJourneyGoal(request: JourneyGoalRequest)
    // 인사이트 선택 결과 저장/루프 생성 요청
    case createLoop(request: InsightSelectRequest)
    // 추천 루프 생성 API 케이스 추가
    case generateLoops(request: LoopRecommendationRequest)
    // 11번 api (루틴 생성)
    case createRoutines(request: RoutineCreateRequest)
    // 루프 1개 재생성
    case regenerateRoutine(request: RoutineRegenerateRequest)
    // (/journey/order api)에 사용
    case getJourneyOrder
}

extension OnboardingAPI: TargetType {
    var baseURL: URL {
        guard let url = URL(string: API.baseURL) else {
            fatalError("Invalid API.baseURL: \(API.baseURL)")
        }
        return url
    }

    var path: String {
        switch self {
        case .createJourneyGoal:
            return "/api/journeys/goals"
        case .createLoop:
            // TODO: 인사이트 선택 API 경로 확정 후 수정
            return "/api/coach/insights"
        case .generateLoops:
            return "/api/goals/loops"
        case .createRoutines:
            return "/api/routines"
        case .regenerateRoutine:
            return "/api/journeys/regenerate"
        case .getJourneyOrder:
            return "/api/journeys/order"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getJourneyOrder:
            return .get
        case .createJourneyGoal, .generateLoops, .createLoop, .createRoutines, .regenerateRoutine:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .getJourneyOrder:
            return .requestPlain
        case let .createJourneyGoal(request):
            return .requestJSONEncodable(request)
        case let .createLoop(request):
            return .requestJSONEncodable(request)
        case let .generateLoops(request):
            return .requestJSONEncodable(request)
        case let .createRoutines(request):
            return .requestJSONEncodable(request)
        case let .regenerateRoutine(request):
            return .requestJSONEncodable(request)
        
        }
    }

    /// 인증이 필요한 API이므로 키체인 accessToken을 Authorization 헤더에 포함
    var headers: [String: String]? {
        var header: [String: String] = ["Content-Type": "application/json"]
        if let token = KeychainService.shared.loadToken(), !token.isEmpty {
            header["Authorization"] = "Bearer \(token)"
        }
        return header
    }
}
