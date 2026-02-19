//
//  ChallengeFriendRequestDTOs.swift
//  Loop_On
//
//  Created by 김세은 on 2/10/26.
//

import Foundation

struct ChallengeFriendRequestPageDTO: Decodable {
    let content: [ChallengeFriendRequestItemDTO]
    let pageNumber: Int
    let pageSize: Int
    let totalElements: Int
    let totalPages: Int
    let isFirst: Bool
    let isLast: Bool

    enum CodingKeys: String, CodingKey {
        case content
        case pageNumber
        case pageSize
        case totalElements
        case totalPages
        case isFirst = "first"
        case isLast = "last"
    }
}

struct ChallengeFriendRequestItemDTO: Decodable {
    let requesterId: Int
    let friendImageURL: String?
    let friendNickname: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case requesterId = "requester_id"
        case friendImageURL = "friend_image_url"
        case friendNickname = "friend_nickname"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension ChallengeFriendRequest {
    init(dto: ChallengeFriendRequestItemDTO) {
        self.id = dto.requesterId
        self.name = dto.friendNickname
        self.subtitle = ""
        self.imageURL = dto.friendImageURL
    }
}

struct ChallengeFriendRequestBulkResponse: Decodable {
    let processCount: Int
}

struct ChallengeFriendRequestSingleActionResponse: Decodable {
    let requesterId: Int?
    let receiverId: Int?
    let requesterNickname: String?
    let receiverNickname: String?
    let friendStatus: String?

    enum CodingKeys: String, CodingKey {
        case requesterId = "requesterId"
        case receiverId = "receiverId"
        case requesterNickname = "requesterNickname"
        case receiverNickname = "receiverNickname"
        case friendStatus = "friendStatus"
    }

    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            requesterId = try container.decodeIfPresent(Int.self, forKey: .requesterId)
            receiverId = try container.decodeIfPresent(Int.self, forKey: .receiverId)
            requesterNickname = try container.decodeIfPresent(String.self, forKey: .requesterNickname)
            receiverNickname = try container.decodeIfPresent(String.self, forKey: .receiverNickname)
            friendStatus = try container.decodeIfPresent(String.self, forKey: .friendStatus)
            return
        }

        let single = try decoder.singleValueContainer()
        _ = try? single.decode(String.self)
        requesterId = nil
        receiverId = nil
        requesterNickname = nil
        receiverNickname = nil
        friendStatus = nil
    }
}


