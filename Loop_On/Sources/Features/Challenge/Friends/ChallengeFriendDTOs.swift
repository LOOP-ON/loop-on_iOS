//
//  ChallengeFriendDTOs.swift
//  Loop_On
//
//  Created by 김세은 on 2/7/26.
//

import Foundation

struct ChallengeFriendListItemDTO: Decodable {
    let friendId: Int
    let friendStatus: String?
    let friendImageURL: String?
    let friendNickname: String
    let friendBio: String?
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case friendId = "friend_id"
        case friendStatus = "friend_status"
        case friendImageURL = "friend_image_url"
        case friendNickname = "friend_nickname"
        case friendBio = "friend_bio"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension ChallengeFriend {
    init(dto: ChallengeFriendListItemDTO) {
        self.id = dto.friendId
        self.name = dto.friendNickname
        self.subtitle = dto.friendBio ?? ""
        self.isSelf = false
        self.imageURL = dto.friendImageURL
        self.status = dto.friendStatus
    }
}
