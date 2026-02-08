//
//  JourneyGoalDTOs.swift
//  Loop_On
//
//  Created by 김세은 on 1/22/26.
//

import Foundation

struct JourneyGoalRequest: Encodable {
    let goal: String
    let category: String
}

struct JourneyGoalResponse: Decodable {
    let journeyId: Int
}

struct LoopRecommendationRequest: Encodable {
    let goal: String
    let loopCount: Int
}

/// POST /api/goals/loops 응답. 서버가 camelCase 또는 snake_case 모두 처리
struct LoopRecommendationResponse: Decodable {
    let goalId: Int?
    let goal: String?
    let loops: [RecommendedLoop]

    enum CodingKeys: String, CodingKey {
        case goalId = "goalId"
        case goalIdSnake = "goal_id"
        case goal
        case loops
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        goalId = (try? c.decode(Int.self, forKey: .goalId)) ?? (try? c.decode(Int.self, forKey: .goalIdSnake))
        goal = try? c.decode(String.self, forKey: .goal)
        loops = (try? c.decode([RecommendedLoop].self, forKey: .loops)) ?? []
    }

    struct RecommendedLoop: Decodable {
        let journeyId: Int?
        let goal: String

        enum CodingKeys: String, CodingKey {
            case journeyId = "journeyId"
            case journeyIdSnake = "journey_id"
            case goal
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            journeyId = (try? c.decode(Int.self, forKey: .journeyId)) ?? (try? c.decode(Int.self, forKey: .journeyIdSnake))
            goal = (try? c.decode(String.self, forKey: .goal)) ?? ""
        }
    }
}
