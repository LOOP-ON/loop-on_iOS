//
//  ChallengeCard.swift
//  Loop_On
//
//  Created by 이경민 on 1/22/26.
//

import Foundation

struct ChallengeCard: Identifiable {
    var id: Int { challengeId }
    let challengeId: Int
    let title: String
    let subtitle: String
    let dateText: String
    let hashtags: [String]
    let authorName: String
    /// API 이미지 URL 목록. 비어 있으면 placeholder만 표시 (imageCount 사용)
    let imageUrls: [String]
    var imageCount: Int { imageUrls.isEmpty ? 0 : imageUrls.count }
    let profileImageUrl: String?
    var isLiked: Bool
    var likeCount: Int
    /// 내 글 여부. true일 때만 수정/삭제 버튼 표시. API에 없는 경우 false
    let isMine: Bool

    init(
        challengeId: Int,
        title: String,
        subtitle: String,
        dateText: String,
        hashtags: [String],
        authorName: String,
        imageUrls: [String] = [],
        profileImageUrl: String? = nil,
        isLiked: Bool,
        likeCount: Int = 0,
        isMine: Bool = false
    ) {
        self.challengeId = challengeId
        self.title = title
        self.subtitle = subtitle
        self.dateText = dateText
        self.hashtags = hashtags
        self.authorName = authorName
        self.imageUrls = imageUrls
        self.profileImageUrl = profileImageUrl
        self.isLiked = isLiked
        self.likeCount = likeCount
        self.isMine = isMine
    }

}

extension ChallengeCard {
    static let samplePlaza: [ChallengeCard] = [
        ChallengeCard(
            challengeId: 1,
            title: "세 번째 여정",
            subtitle: "2026 갓생 살기 성공 🍀",
            dateText: "2026.01.01",
            hashtags: ["#생활루틴", "#갓생", "#2026"],
            authorName: "서리",
            imageUrls: [],
            profileImageUrl: nil,
            isLiked: false,
            likeCount: 0
        ),
        ChallengeCard(
            challengeId: 2,
            title: "네 번째 여정",
            subtitle: "하루 루틴 완주",
            dateText: "2026.01.02",
            hashtags: ["#아침루틴", "#습관"],
            authorName: "민지",
            imageUrls: [],
            profileImageUrl: nil,
            isLiked: true,
            likeCount: 5
        ),
        ChallengeCard(
            challengeId: 3,
            title: "다섯 번째 여정",
            subtitle: "운동 30분 완료",
            dateText: "2026.01.03",
            hashtags: ["#운동", "#헬스"],
            authorName: "지훈",
            imageUrls: [],
            profileImageUrl: nil,
            isLiked: false,
            likeCount: 2
        ),
        ChallengeCard(
            challengeId: 4,
            title: "여섯 번째 여정",
            subtitle: "독서 20쪽",
            dateText: "2026.01.04",
            hashtags: ["#독서", "#자기계발"],
            authorName: "서연",
            imageUrls: [],
            profileImageUrl: nil,
            isLiked: true,
            likeCount: 3
        ),
        ChallengeCard(
            challengeId: 5,
            title: "일곱 번째 여정",
            subtitle: "물 2L 마시기",
            dateText: "2026.01.05",
            hashtags: ["#건강", "#수분"],
            authorName: "도윤",
            imageUrls: [],
            profileImageUrl: nil,
            isLiked: false,
            likeCount: 1
        ),
        ChallengeCard(
            challengeId: 6,
            title: "여덟 번째 여정",
            subtitle: "산책 40분",
            dateText: "2026.01.06",
            hashtags: ["#산책", "#리프레시"],
            authorName: "하늘",
            imageUrls: [],
            profileImageUrl: nil,
            isLiked: false,
            likeCount: 0
        )
    ]

    static let sampleFriend: [ChallengeCard] = [
        ChallengeCard(
            challengeId: 7,
            title: "친구 여정 1",
            subtitle: "요가 15분",
            dateText: "2026.01.07",
            hashtags: ["#요가", "#스트레칭"],
            authorName: "수아",
            imageUrls: [],
            profileImageUrl: nil,
            isLiked: true,
            likeCount: 4
        ),
        ChallengeCard(
            challengeId: 8,
            title: "친구 여정 2",
            subtitle: "일기 쓰기",
            dateText: "2026.01.08",
            hashtags: ["#일기", "#감사"],
            authorName: "윤호",
            imageUrls: [],
            profileImageUrl: nil,
            isLiked: false,
            likeCount: 0
        ),
        ChallengeCard(
            challengeId: 9,
            title: "친구 여정 3",
            subtitle: "러닝 5km",
            dateText: "2026.01.09",
            hashtags: ["#러닝", "#건강"],
            authorName: "하준",
            imageUrls: [],
            profileImageUrl: nil,
            isLiked: true,
            likeCount: 2
        )
    ]

    static let sampleExpedition: [ChallengeCard] = [
        ChallengeCard(
            challengeId: 10,
            title: "탐험대 여정 1",
            subtitle: "공동 챌린지 시작",
            dateText: "2026.01.10",
            hashtags: ["#팀플레이", "#챌린지"],
            authorName: "탐험대A",
            imageUrls: [],
            profileImageUrl: nil,
            isLiked: false,
            likeCount: 0
        ),
        ChallengeCard(
            challengeId: 11,
            title: "탐험대 여정 2",
            subtitle: "새 목표 공유",
            dateText: "2026.01.11",
            hashtags: ["#목표", "#공유"],
            authorName: "탐험대B",
            imageUrls: [],
            profileImageUrl: nil,
            isLiked: true,
            likeCount: 1
        ),
        ChallengeCard(
            challengeId: 12,
            title: "탐험대 여정 3",
            subtitle: "주간 회고",
            dateText: "2026.01.12",
            hashtags: ["#회고", "#성장"],
            authorName: "탐험대C",
            imageUrls: [],
            profileImageUrl: nil,
            isLiked: false,
            likeCount: 0
        )
    ]
}
