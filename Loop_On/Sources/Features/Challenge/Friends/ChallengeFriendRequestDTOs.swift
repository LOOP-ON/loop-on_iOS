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
