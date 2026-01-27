//
//  ChallengeExpedition.swift
//  Loop_On
//
//  Created by 김세은 on 1/22/26.
//

import SwiftUI

struct ChallengeExpedition: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let progressText: String
    let leaderName: String
    let isPrivate: Bool
    let isMember: Bool
    let isOwner: Bool
}

extension ChallengeExpedition {
    var actionTitle: String {
        if isMember {
            return isOwner ? "삭제" : "탈퇴"
        }
        return "가입"
    }

    var actionColor: Color {
        return Color(.primaryColorVarient65)
    }
}

extension ChallengeExpedition {
    static let sampleMyExpeditions: [ChallengeExpedition] = [
        ChallengeExpedition(
            name: "갓생 루틴 공유방",
            category: "생활 루틴",
            progressText: "8/10",
            leaderName: "서리",
            isPrivate: true,
            isMember: true,
            isOwner: true
        ),
        ChallengeExpedition(
            name: "SQLD 자격증 준비방",
            category: "역량 강화",
            progressText: "35/50",
            leaderName: "쥬디",
            isPrivate: false,
            isMember: true,
            isOwner: false
        )
    ]

    static let sampleRecommendedExpeditions: [ChallengeExpedition] = [
        ChallengeExpedition(
            name: "하루 세 질문",
            category: "내면 관리",
            progressText: "13/25",
            leaderName: "키미",
            isPrivate: true,
            isMember: false,
            isOwner: false
        ),
        ChallengeExpedition(
            name: "GTQi 자격증 준비방",
            category: "역량 강화",
            progressText: "3/15",
            leaderName: "써니",
            isPrivate: false,
            isMember: false,
            isOwner: false
        ),
        ChallengeExpedition(
            name: "취준생 공부방",
            category: "역량 강화",
            progressText: "35/50",
            leaderName: "핀",
            isPrivate: true,
            isMember: false,
            isOwner: false
        ),
        ChallengeExpedition(
            name: "하루 독서 챌린지",
            category: "생활 루틴",
            progressText: "12/20",
            leaderName: "레오",
            isPrivate: false,
            isMember: false,
            isOwner: false
        ),
        ChallengeExpedition(
            name: "감정 일기 모임",
            category: "내면 관리",
            progressText: "7/18",
            leaderName: "루비",
            isPrivate: false,
            isMember: false,
            isOwner: false
        )
    ]
}
