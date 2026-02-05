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
    @Published private var commentsByCard: [UUID: [ChallengeComment]] = [:]

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

    func didTapEdit(id: UUID) {
        // TODO: API 연결 시 게시물 수정 화면 이동 처리 (id)
    }

    func didTapDelete(id: UUID) {
        // TODO: API 연결 시 게시물 삭제 처리 (id)
    }

    func loadComments(for cardId: UUID) -> [ChallengeComment] {
        if let cached = commentsByCard[cardId] {
            return cached
        }
        // TODO: API 연결 시 댓글 조회 요청 처리 (cardId)
        let comments = ChallengeComment.sample
        commentsByCard[cardId] = comments
        return comments
    }
}
