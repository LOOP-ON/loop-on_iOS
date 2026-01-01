//
//  UserDTO.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import Foundation

struct UserDTO: Codable {
    let userId: String
    let name: String
    let profileImage: String?
    let userBio: String
    let createdAt: String
    
    // Codable을 위한 CodingKeys
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name = "user_name"
        case profileImage = "profile_image"
        case userBio = "user_bio"
        case createdAt = "created_at"
    }
}

extension UserDTO {
    // DTO를 도메인 모델로 변환
    func toDomain() -> UserModel {
        return UserModel(
            id: userId,
            name: name,
            profileImageURL: profileImage,
            bio: userBio
        )
    }
}
