//
//  ChallengePlazaView.swift
//  Loop_On
//
//  Created by 이경민 on 1/22/26.
//

import SwiftUI

struct ChallengePlazaView: View {
    @StateObject private var viewModel = ChallengePlazaViewModel()

    var body: some View {
        ChallengeFeedView(
            cards: $viewModel.cards,
            emptyMessage: viewModel.emptyMessage,
            onLikeTap: viewModel.didToggleLike,
            onEdit: viewModel.didTapEdit,
            onDelete: viewModel.didTapDelete
        )
    }
}

#Preview {
    ChallengePlazaView()
}
