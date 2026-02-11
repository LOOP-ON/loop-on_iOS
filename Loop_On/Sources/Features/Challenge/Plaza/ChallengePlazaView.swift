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
    /// 상위에서 삭제 팝업을 띄우고 싶을 때 호출되는 콜백 (id, 실제 삭제 실행 클로저)
    var onRequestDelete: ((Int, @escaping (Int) -> Void) -> Void)? = nil
    /// 게시물 수정 시 상위에서 챌린지 수정 화면을 열 때 사용 (id 전달)
    var onEdit: ((Int) -> Void)? = nil

    var body: some View {
        ChallengeFeedView(
            isLoading: viewModel.isLoading,
            loadError: viewModel.loadError,
            cards: $viewModel.cards,
            emptyMessage: viewModel.emptyMessage,
            onLikeTap: viewModel.didToggleLike,
            onEdit: onEdit ?? viewModel.didTapEdit,
            onDelete: { id in
                if let onRequestDelete = onRequestDelete {
                    // 메서드 참조 대신 래핑해서 label 문제 해결
                    onRequestDelete(id) { performId in
                        viewModel.didTapDelete(id: performId)
                    }
                } else {
                    viewModel.didTapDelete(id: id)
                }
            },
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
        .environment(NavigationRouter())
}
