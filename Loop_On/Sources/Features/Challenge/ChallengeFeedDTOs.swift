//
//  ChallengeFeedDTOs.swift
//  Loop_On
//
//  GET /api/challenges 피드 조회용 DTO. ChallengeAPI·ChallengePlazaViewModel에서 공통 사용.
//

import Foundation

/// 피드 한 건 (트렌딩/친구 공통)
struct ChallengeFeedItemDTO: Decodable {
    let challengeId: Int
    let journeySequence: Int
    let imageUrls: [String]
    let content: String
    let hashtags: [String]
    let createdAt: String
    let nickname: String
    let profileImageUrl: String?
    let isLiked: Bool
    let likeCount: Int
    /// 내 글 여부. 없으면 false (여정광장에서는 내 글 미노출)
    let isMine: Bool?
}

/// 피드 페이지 (trendingChallenges / friendChallenges)
struct ChallengeFeedPageDTO: Decodable {
    let content: [ChallengeFeedItemDTO]
    let size: Int?
    let number: Int?
    let first: Bool?
    let last: Bool?
    let empty: Bool?
}

/// GET /api/challenges 피드 조회 응답 data
struct ChallengeFeedDataDTO: Decodable {
    let trendingChallenges: ChallengeFeedPageDTO
    let friendChallenges: ChallengeFeedPageDTO
}
