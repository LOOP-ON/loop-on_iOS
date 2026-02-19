//
//  ProfileDTO.swift
//  Loop_On
//
//  Created by Auto on 1/14/26.
//

import Foundation

struct ProfileDTO: Codable {
    let userId: String?
    let name: String
    let nickname: String
    let birthday: String
    let profileImage: String?
    
    // Codable을 위한 CodingKeys
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name = "user_name"
        case nickname = "nickname"
        case birthday = "birthday"
        case profileImage = "profile_image"
    }
}

extension ProfileDTO {
    // DTO를 도메인 모델로 변환
    func toDomain() -> ProfileModel {
        return ProfileModel(
            id: userId,
            name: name,
            nickname: nickname,
            birthday: birthday,
            profileImageURL: profileImage
        )
    }
}

extension ProfileModel {
    // 도메인 모델을 DTO로 변환
    func toDTO() -> ProfileDTO {
        return ProfileDTO(
            userId: id,
            name: name,
            nickname: nickname,
            birthday: birthday,
            profileImage: profileImageURL
        )
    }
}

struct ProfileUpdateRequestDTO: Encodable {
    let nickname: String
    let bio: String
    let statusMessage: String
    let profileImageUrl: String
    let visibility: String
}
