//
//  ChallengeFeedView.swift
//  Loop_On
//
//  Created by 이경민 on 1/22/26.
//

import SwiftUI

struct ChallengeFeedView: View {
    @Binding var cards: [ChallengeCard]
    let emptyMessage: String
    var onLikeTap: ((UUID, Bool) -> Void)?
    var onEdit: ((UUID) -> Void)?
    var onDelete: ((UUID) -> Void)?

    var body: some View {
        ScrollView {
            if cards.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.gray.opacity(0.6))
                    Text(emptyMessage)
                        .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundStyle(Color.gray)
                }
                .frame(maxWidth: .infinity, minHeight: 260)
                .padding(.top, 40)
            } else {
                VStack(spacing: 16) {
                    ForEach($cards) { $card in
                        ChallengeCardView(
                            card: $card,
                            onLikeTap: onLikeTap,
                            onEdit: onEdit,
                            onDelete: onDelete
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
        }
        .scrollIndicators(.hidden)
    }
}
