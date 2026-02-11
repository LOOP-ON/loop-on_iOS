//
//  ChallengeExpeditionDTOs.swift
//  Loop_On
//
//  Created by Codex on 2/11/26.
//

import Foundation

struct CreateExpeditionRequest: Encodable {
    let title: String
    let capacity: Int
    let visibility: String
    let category: String
    let password: String?
}

struct CreateExpeditionResponseDTO: Decodable {
    let expeditionId: Int
}

struct ChallengeMyExpeditionListDTO: Decodable {
    let expeditionGetResponses: [ChallengeExpeditionListItemDTO]
}

struct ChallengeExpeditionListItemDTO: Decodable {
    let expeditionId: Int
    let title: String
    let category: String
    let admin: String
    let currentMembers: Int
    let capacity: Int
    let visibility: String

    enum CodingKeys: String, CodingKey {
        case expeditionId
        case title
        case category
        case admin
        case currentMembers
        case capacity
        case visibility
    }
}

extension ChallengeExpedition {
    static func categoryCode(from displayName: String) -> String {
        switch displayName {
        case "역량 강화":
            return "SKILL"
        case "생활 루틴":
            return "ROUTINE"
        case "내면 관리":
            return "MIND"
        default:
            return "SKILL"
        }
    }

    init(dto: ChallengeExpeditionListItemDTO) {
        self.id = dto.expeditionId
        self.name = dto.title
        self.category = Self.categoryText(from: dto.category)
        self.progressText = "\(dto.currentMembers)/\(dto.capacity)"
        self.leaderName = dto.admin
        self.isPrivate = dto.visibility.uppercased() != "PUBLIC"
        self.isMember = true
        self.isOwner = false
    }

    private static func categoryText(from raw: String) -> String {
        switch raw.uppercased() {
        case "SKILL":
            return "역량 강화"
        case "ROUTINE", "LIFE_ROUTINE", "LIFE":
            return "생활 루틴"
        case "MIND", "MINDSET", "INNER", "INSIGHT":
            return "내면 관리"
        default:
            return raw
        }
    }
}
