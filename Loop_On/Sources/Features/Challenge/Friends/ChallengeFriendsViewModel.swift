//
//  ChallengeFriendsViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 1/22/26.
//

import Foundation

final class ChallengeFriendsViewModel: ObservableObject {
    @Published var cards: [ChallengeCard]
    let emptyMessage: String

    init(
        cards: [ChallengeCard] = ChallengeCard.sampleFriend,
        emptyMessage: String = "친구의 여정이 아직 없어요."
    ) {
        self.cards = cards
        self.emptyMessage = emptyMessage
    }
}
