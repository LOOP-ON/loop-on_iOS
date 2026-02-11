//
//  ChallengeFeedView.swift
//  Loop_On
//
//  Created by 김세은 on 1/22/26.
//

import SwiftUI

struct ChallengeFeedView: View {
    var isLoading: Bool = false
    var loadError: String? = nil
    @Binding var cards: [ChallengeCard]
    let emptyMessage: String
    var onLikeTap: ((Int, Bool) -> Void)?
    var onEdit: ((Int) -> Void)?
    var onDelete: ((Int) -> Void)?
    /// (challengeId, completion(댓글 목록)) — 비동기 댓글 조회 후 시트에서 사용
    var onCommentTap: ((Int, @escaping ([ChallengeComment]) -> Void) -> Void)?
    /// (challengeId, page, completion(추가 댓글, hasMore)) — 댓글 무한 스크롤
    var onLoadMoreComments: ((Int, Int, @escaping ([ChallengeComment], Bool) -> Void) -> Void)?
    /// (commentId, isLiked, completion(success)) — 댓글 좋아요/취소
    var onCommentLike: ((Int, Bool, @escaping (Bool) -> Void) -> Void)?
    /// (challengeId, content, parentId, replyToName?, completion(새 댓글 또는 에러)) — 댓글 등록
    var onPostComment: ((Int, String, Int, String?, @escaping (Result<ChallengeComment, Error>) -> Void) -> Void)?
    /// (challengeId, commentId, completion(success)) — 댓글 삭제
    var onDeleteComment: ((Int, Int, @escaping (Bool) -> Void) -> Void)?
    /// 타인 프로필 열기 (오버레이 시 탭바 유지)
    var onOpenOtherProfile: ((Int) -> Void)? = nil

    var body: some View {
        ScrollView {
            if let error = loadError, cards.isEmpty {
                VStack(spacing: 12) {
                    Text(error)
                        .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, minHeight: 260)
                .padding(.top, 40)
            } else if cards.isEmpty {
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
                            onDelete: onDelete,
                            onCommentTap: onCommentTap,
                            onLoadMoreComments: onLoadMoreComments,
                            onCommentLike: onCommentLike,
                            onPostComment: onPostComment,
                            onDeleteComment: onDeleteComment,
                            onOpenOtherProfile: onOpenOtherProfile
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
        }
        .scrollIndicators(.hidden)
        .overlay {
            if isLoading, cards.isEmpty {
                ProgressView()
                    .scaleEffect(1.2)
            }
        }
    }
}
