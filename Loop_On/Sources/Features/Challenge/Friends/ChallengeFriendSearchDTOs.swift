//
//  ChallengeFriendSearchDTOs.swift
//  Loop_On
//
//  Created by 김세은 on 2/7/26.
//

import Foundation

struct ChallengeFriendSearchPageDTO: Decodable {
    let content: [ChallengeFriendSearchItemDTO]
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

struct ChallengeFriendSearchItemDTO: Decodable {
    let nickname: String
    let bio: String
    let profileImageURL: String?
    let userId: Int

    enum CodingKeys: String, CodingKey {
        case nickname
        case bio
        case profileImageURL = "profile_image_url"
        case userId = "user_id"
    }
}

struct ChallengeFriendSearchResult: Identifiable {
    let id: Int
    let nickname: String
    let bio: String
    let profileImageURL: String?
    var isRequestSent: Bool
    var isFriend: Bool
}

extension ChallengeFriendSearchResult {
    init(dto: ChallengeFriendSearchItemDTO) {
        self.id = dto.userId
        self.nickname = dto.nickname
        self.bio = dto.bio
        self.profileImageURL = dto.profileImageURL
        self.isRequestSent = false
        self.isFriend = false
    }
}

struct FriendRequestSendRequest: Encodable {
    let receiverId: Int

    enum CodingKeys: String, CodingKey {
        case receiverId = "receiverId"
    }
}

struct FriendRequestSendResponse: Decodable {
    let requesterId: Int
    let receiverId: Int
    let requesterNickname: String
    let receiverNickname: String

    enum CodingKeys: String, CodingKey {
        case requesterId = "requesterId"
        case receiverId = "receiverId"
        case requesterNickname = "requesterNickname"
        case receiverNickname = "receiverNickname"
    }
}
