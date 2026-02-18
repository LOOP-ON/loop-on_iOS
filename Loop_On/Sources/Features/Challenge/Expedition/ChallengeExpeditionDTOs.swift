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

struct JoinExpeditionRequest: Encodable {
    let expeditionId: Int
    let expeditionVisibility: String
    let password: String?
}

struct ExpeditionExpelRequest: Encodable {
    let userId: Int
}

struct JoinExpeditionResponseDTO: Decodable {
    let expeditionUserId: Int?
}

struct CreateExpeditionResponseDTO: Decodable {
    let expeditionId: Int
}

struct ChallengeMyExpeditionListDTO: Decodable {
    let expeditionGetResponses: [ChallengeExpeditionListItemDTO]

    enum CodingKeys: String, CodingKey {
        case expeditionGetResponses
        case expeditionGetResponsesSnake = "expedition_get_responses"
        case expeditions
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        expeditionGetResponses = (try? c.decode([ChallengeExpeditionListItemDTO].self, forKey: .expeditionGetResponses))
            ?? (try? c.decode([ChallengeExpeditionListItemDTO].self, forKey: .expeditionGetResponsesSnake))
            ?? (try? c.decode([ChallengeExpeditionListItemDTO].self, forKey: .expeditions))
            ?? []
    }
}

struct ChallengeExpeditionSearchPageDTO: Decodable {
    let content: [ChallengeExpeditionListItemDTO]
}

struct ExpeditionMemberListResponseDTO: Decodable {
    let isHost: Bool
    let currentMemberCount: Int
    let maxMemberCount: Int
    let userList: [ExpeditionMemberDTO]
}

struct ExpeditionMemberDTO: Decodable {
    let userId: Int
    let nickname: String
    let profileImageUrl: String?
    let isMe: Bool
    let isHost: Bool
    let friendStatus: String
    let expeditionUserStatus: String
}

struct ExpeditionChallengePageDTO: Decodable {
    let content: [ExpeditionChallengeItemDTO]
    let number: Int?
    let last: Bool?
    let empty: Bool?
}

struct ExpeditionChallengeItemDTO: Decodable {
    let challengeId: Int
    let journeyNumber: Int
    let imageUrls: [String]
    let content: String
    let hashtags: [String]
    let createdAt: String
    let nickName: String
    let profileImageUrl: String?
    let isLiked: Bool
    let likeCount: Int

    enum CodingKeys: String, CodingKey {
        case challengeId
        case challengeIdSnake = "challenge_id"
        case journeyNumber
        case journeySequence
        case journeyNumberSnake = "journey_number"
        case imageUrls
        case imageUrlsSnake = "image_urls"
        case content
        case hashtags
        case hashtagList
        case createdAt
        case createdAtSnake = "created_at"
        case nickName
        case nickname
        case nickNameSnake = "nick_name"
        case profileImageUrl
        case profileImageUrlSnake = "profile_image_url"
        case isLiked
        case isLikedSnake = "is_liked"
        case likeCount
        case likeCountSnake = "like_count"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        challengeId = (try? c.decode(Int.self, forKey: .challengeId))
            ?? (try? c.decode(Int.self, forKey: .challengeIdSnake))
            ?? 0
        journeyNumber = (try? c.decode(Int.self, forKey: .journeyNumber))
            ?? (try? c.decode(Int.self, forKey: .journeySequence))
            ?? (try? c.decode(Int.self, forKey: .journeyNumberSnake))
            ?? 0
        imageUrls = (try? c.decode([String].self, forKey: .imageUrls))
            ?? (try? c.decode([String].self, forKey: .imageUrlsSnake))
            ?? []
        content = (try? c.decode(String.self, forKey: .content)) ?? ""
        hashtags = (try? c.decode([String].self, forKey: .hashtags))
            ?? (try? c.decode([String].self, forKey: .hashtagList))
            ?? []
        createdAt = (try? c.decode(String.self, forKey: .createdAt))
            ?? (try? c.decode(String.self, forKey: .createdAtSnake))
            ?? ""
        nickName = (try? c.decode(String.self, forKey: .nickName))
            ?? (try? c.decode(String.self, forKey: .nickname))
            ?? (try? c.decode(String.self, forKey: .nickNameSnake))
            ?? "사용자"
        profileImageUrl = (try? c.decodeIfPresent(String.self, forKey: .profileImageUrl))
            ?? (try? c.decodeIfPresent(String.self, forKey: .profileImageUrlSnake))
        isLiked = (try? c.decode(Bool.self, forKey: .isLiked))
            ?? (try? c.decode(Bool.self, forKey: .isLikedSnake))
            ?? false
        likeCount = (try? c.decode(Int.self, forKey: .likeCount))
            ?? (try? c.decode(Int.self, forKey: .likeCountSnake))
            ?? 0
    }
}

struct ExpeditionSettingDTO: Decodable {
    let expeditionId: Int
    let title: String
    let category: String
    let admin: String
    let currentUsers: Int
    let capacity: Int
    let visibility: String
    let isAdmin: Bool
    let password: String?

    enum CodingKeys: String, CodingKey {
        case expeditionId
        case title
        case category
        case admin
        case currentUsers
        case currentMembers
        case userLimit
        case capacity
        case visibility
        case isAdmin
        case password
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        expeditionId = (try? c.decode(Int.self, forKey: .expeditionId)) ?? 0
        title = (try? c.decode(String.self, forKey: .title)) ?? ""
        category = (try? c.decode(String.self, forKey: .category)) ?? "GROWTH"
        admin = (try? c.decode(String.self, forKey: .admin)) ?? ""
        currentUsers = (try? c.decode(Int.self, forKey: .currentUsers))
            ?? (try? c.decode(Int.self, forKey: .currentMembers))
            ?? 0
        capacity = (try? c.decode(Int.self, forKey: .capacity))
            ?? (try? c.decode(Int.self, forKey: .userLimit))
            ?? 0
        visibility = (try? c.decode(String.self, forKey: .visibility)) ?? "PUBLIC"
        isAdmin = (try? c.decode(Bool.self, forKey: .isAdmin)) ?? false
        password = try? c.decodeIfPresent(String.self, forKey: .password)
    }
}

struct UpdateExpeditionSettingRequest: Encodable {
    let title: String
    let visibility: String
    let password: String?
    let userLimit: Int
}

struct ChallengeExpeditionListItemDTO: Decodable {
    let expeditionId: Int
    let title: String
    let category: String
    let admin: String
    let currentMembers: Int
    let capacity: Int
    let visibility: String
    let isJoined: Bool
    let isAdmin: Bool
    let canJoin: Bool

    enum CodingKeys: String, CodingKey {
        case expeditionId
        case expeditionID = "expedition_id"
        case title
        case category
        case admin
        case adminNickname = "adminNickname"
        case adminNicknameSnake = "admin_nickname"
        case currentMembers
        case currentUsers
        case currentMember = "currentMember"
        case currentMemberCount = "currentMemberCount"
        case currentMembersSnake = "current_members"
        case memberCount = "memberCount"
        case capacity
        case visibilitySnake = "visibility_type"
        case visibility
        case isJoined
        case isAdmin
        case canJoin
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        expeditionId = (try? c.decode(Int.self, forKey: .expeditionId))
            ?? (try? c.decode(Int.self, forKey: .expeditionID))
            ?? 0
        title = (try? c.decode(String.self, forKey: .title)) ?? ""
        category = (try? c.decode(String.self, forKey: .category)) ?? "GROWTH"
        admin = (try? c.decode(String.self, forKey: .admin))
            ?? (try? c.decode(String.self, forKey: .adminNickname))
            ?? (try? c.decode(String.self, forKey: .adminNicknameSnake))
            ?? "운영자"
        currentMembers = (try? c.decode(Int.self, forKey: .currentMembers))
            ?? (try? c.decode(Int.self, forKey: .currentUsers))
            ?? (try? c.decode(Int.self, forKey: .currentMember))
            ?? (try? c.decode(Int.self, forKey: .currentMemberCount))
            ?? (try? c.decode(Int.self, forKey: .currentMembersSnake))
            ?? (try? c.decode(Int.self, forKey: .memberCount))
            ?? 0
        capacity = (try? c.decode(Int.self, forKey: .capacity)) ?? 0
        visibility = (try? c.decode(String.self, forKey: .visibility))
            ?? (try? c.decode(String.self, forKey: .visibilitySnake))
            ?? "PUBLIC"
        isJoined = (try? c.decode(Bool.self, forKey: .isJoined)) ?? false
        isAdmin = (try? c.decode(Bool.self, forKey: .isAdmin)) ?? false
        canJoin = (try? c.decode(Bool.self, forKey: .canJoin)) ?? true
    }
}

extension ChallengeExpedition {
    static func categoryCode(from displayName: String) -> String {
        switch displayName {
        case "역량 강화":
            return "GROWTH"
        case "생활 루틴":
            return "ROUTINE"
        case "내면 관리":
            return "MENTAL"
        default:
            return "GROWTH"
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
        self.isOwner = dto.isAdmin
        self.canJoin = false
    }

    init(dto: ChallengeExpeditionListItemDTO, isMember: Bool) {
        self.id = dto.expeditionId
        self.name = dto.title
        self.category = Self.categoryText(from: dto.category)
        self.progressText = "\(dto.currentMembers)/\(dto.capacity)"
        self.leaderName = dto.admin
        self.isPrivate = dto.visibility.uppercased() != "PUBLIC"
        self.isMember = isMember
        self.isOwner = dto.isAdmin
        self.canJoin = dto.canJoin
    }

    private static func categoryText(from raw: String) -> String {
        switch raw.uppercased() {
        case "SKILL", "GROWTH":
            return "역량 강화"
        case "ROUTINE", "LIFE_ROUTINE", "LIFE":
            return "생활 루틴"
        case "MENTAL", "MIND", "MINDSET", "INNER", "INSIGHT":
            return "내면 관리"
        default:
            return raw
        }
    }
}
