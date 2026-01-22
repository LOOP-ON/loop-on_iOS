//
//  ChallengeCard.swift
//  Loop_On
//
//  Created by 이경민 on 1/22/26.
//

import Foundation

struct ChallengeCard: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let dateText: String
    let hashtags: [String]
    let authorName: String
    let imageCount: Int
    var isLiked: Bool
}

extension ChallengeCard {
    static let samplePlaza: [ChallengeCard] = [
        ChallengeCard(
            title: "세 번째 여정",
            subtitle: "2026 갓생 살기 성공 🍀",
            dateText: "2026.01.01",
            hashtags: ["#생활루틴", "#갓생", "#2026"],
            authorName: "서리",
            imageCount: 6,
            isLiked: false
        ),
        ChallengeCard(
            title: "네 번째 여정",
            subtitle: "하루 루틴 완주",
            dateText: "2026.01.02",
            hashtags: ["#아침루틴", "#습관"],
            authorName: "민지",
            imageCount: 3,
            isLiked: true
        ),
        ChallengeCard(
            title: "다섯 번째 여정",
            subtitle: "운동 30분 완료",
            dateText: "2026.01.03",
            hashtags: ["#운동", "#헬스"],
            authorName: "지훈",
            imageCount: 4,
            isLiked: false
        ),
        ChallengeCard(
            title: "여섯 번째 여정",
            subtitle: "독서 20쪽",
            dateText: "2026.01.04",
            hashtags: ["#독서", "#자기계발"],
            authorName: "서연",
            imageCount: 2,
            isLiked: true
        ),
        ChallengeCard(
            title: "일곱 번째 여정",
            subtitle: "물 2L 마시기",
            dateText: "2026.01.05",
            hashtags: ["#건강", "#수분"],
            authorName: "도윤",
            imageCount: 5,
            isLiked: false
        ),
        ChallengeCard(
            title: "여덟 번째 여정",
            subtitle: "산책 40분",
            dateText: "2026.01.06",
            hashtags: ["#산책", "#리프레시"],
            authorName: "하늘",
            imageCount: 3,
            isLiked: false
        )
    ]

    static let sampleFriend: [ChallengeCard] = [
        ChallengeCard(
            title: "친구 여정 1",
            subtitle: "요가 15분",
            dateText: "2026.01.07",
            hashtags: ["#요가", "#스트레칭"],
            authorName: "수아",
            imageCount: 3,
            isLiked: true
        ),
        ChallengeCard(
            title: "친구 여정 2",
            subtitle: "일기 쓰기",
            dateText: "2026.01.08",
            hashtags: ["#일기", "#감사"],
            authorName: "윤호",
            imageCount: 2,
            isLiked: false
        ),
        ChallengeCard(
            title: "친구 여정 3",
            subtitle: "러닝 5km",
            dateText: "2026.01.09",
            hashtags: ["#러닝", "#건강"],
            authorName: "하준",
            imageCount: 4,
            isLiked: true
        )
    ]

    static let sampleExpedition: [ChallengeCard] = [
        ChallengeCard(
            title: "탐험대 여정 1",
            subtitle: "공동 챌린지 시작",
            dateText: "2026.01.10",
            hashtags: ["#팀플레이", "#챌린지"],
            authorName: "탐험대A",
            imageCount: 6,
            isLiked: false
        ),
        ChallengeCard(
            title: "탐험대 여정 2",
            subtitle: "새 목표 공유",
            dateText: "2026.01.11",
            hashtags: ["#목표", "#공유"],
            authorName: "탐험대B",
            imageCount: 3,
            isLiked: true
        ),
        ChallengeCard(
            title: "탐험대 여정 3",
            subtitle: "주간 회고",
            dateText: "2026.01.12",
            hashtags: ["#회고", "#성장"],
            authorName: "탐험대C",
            imageCount: 4,
            isLiked: false
        )
    ]
}
