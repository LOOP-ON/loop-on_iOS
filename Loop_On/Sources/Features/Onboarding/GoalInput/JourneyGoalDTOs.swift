import Foundation

struct GoalRecommendationData: Decodable {
    let recommendations: [String]
    
    enum CodingKeys: String, CodingKey {
        case recommendations
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.recommendations = (try? container.decode([String].self, forKey: .recommendations)) ?? []
    }
}

// (/journeys/order) api에 사용
struct JourneyOrderData: Decodable {
    let order: Int
}

struct JourneyGoalRequest: Encodable {
    let goal: String
    let category: String
}

// /api/journeys/goals는 현재 recommendations를 내려주므로
// 공통 BaseResponse<T>의 T는 GoalRecommendationData를 사용한다.

struct LoopRecommendationRequest: Encodable {
    let goal: String
    let loopCount: Int
}

struct LoopRecommendationResponse: Decodable {
    let goalId: Int?
    let goal: String?
    let loops: [RecommendedLoop]

    enum CodingKeys: String, CodingKey {
        case goalId = "goalId"
        case goalIdSnake = "goal_id"
        case goal, loops
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
