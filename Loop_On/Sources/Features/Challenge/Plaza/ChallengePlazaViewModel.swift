//
//  ChallengePlazaViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 1/22/26.
//

import Foundation

final class ChallengePlazaViewModel: ObservableObject {
    @Published var cards: [ChallengeCard]
    let emptyMessage: String

    init(
        cards: [ChallengeCard] = ChallengeCard.samplePlaza,
        emptyMessage: String = "여정 광장에 표시할 여정이 없어요."
    ) {
        self.cards = cards
        self.emptyMessage = emptyMessage
    }

    func didToggleLike(id: UUID, isLiked: Bool) {
        // TODO: API 연결 시 좋아요/취소 요청 처리 (id, isLiked)
    }
}
