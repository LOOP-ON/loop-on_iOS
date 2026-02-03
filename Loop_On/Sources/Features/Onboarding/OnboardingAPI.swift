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
        }
    }

    var method: Moya.Method {
        switch self {
        case .createJourneyGoal, .createLoop:
            return .post
        }
    }

    var task: Task {
        switch self {
        case let .createJourneyGoal(request):
            return .requestJSONEncodable(request)
        case let .createLoop(request):
            return .requestJSONEncodable(request)
        }
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}
