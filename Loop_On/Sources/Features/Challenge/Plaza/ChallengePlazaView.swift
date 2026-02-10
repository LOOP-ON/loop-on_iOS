//
//  ChallengePlazaView.swift
//  Loop_On
//
//  Created by 이경민 on 1/22/26.
//

import SwiftUI

struct ChallengePlazaView: View {
    @StateObject private var viewModel = ChallengePlazaViewModel()
    var onOpenOtherProfile: ((Int) -> Void)? = nil

    var body: some View {
        ChallengeFeedView(
            isLoading: viewModel.isLoading,
            loadError: viewModel.loadError,
            cards: $viewModel.cards,
            emptyMessage: viewModel.emptyMessage,
            onLikeTap: viewModel.didToggleLike,
            onEdit: viewModel.didTapEdit,
            onDelete: viewModel.didTapDelete,
            onCommentTap: viewModel.loadComments,
            onLoadMoreComments: viewModel.loadMoreComments,
            onCommentLike: viewModel.likeComment,
            onPostComment: { challengeId, content, parentId, replyToName, completion in
                viewModel.postComment(challengeId: challengeId, content: content, parentId: parentId, replyToName: replyToName) { result in
                    completion(result.mapError { $0 as Error })
                }
            },
            onDeleteComment: { challengeId, commentId, completion in
                viewModel.deleteComment(challengeId: challengeId, commentId: commentId) { result in
                    completion((try? result.get()) != nil)
                }
            },
            onOpenOtherProfile: onOpenOtherProfile
        )
        .onAppear {
            if viewModel.cards.isEmpty {
                viewModel.loadFeed()
            }
        }
    }
}

#Preview {
    ChallengePlazaView()
}
