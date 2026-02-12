//
//  ChallengeCommentSheetView.swift
//  Loop_On
//
//  Created by 김세은 on 2/4/26.
//

import SwiftUI

struct ChallengeCommentSheetView: View {
    let challengeId: Int
    let onClose: () -> Void
    /// (challengeId, nextPage, completion(추가 댓글, hasMore))
    var onLoadMore: ((Int, Int, @escaping ([ChallengeComment], Bool) -> Void) -> Void)?
    /// (commentId, isLiked, completion(success))
    var onCommentLike: ((Int, Bool, @escaping (Bool) -> Void) -> Void)?
    /// (challengeId, content, parentId, replyToName?, completion(새 댓글 또는 에러))
    var onPostComment: ((Int, String, Int, String?, @escaping (Result<ChallengeComment, Error>) -> Void) -> Void)?
    /// (challengeId, commentId, completion(success))
    var onDeleteComment: ((Int, Int, @escaping (Bool) -> Void) -> Void)?

    @State private var inputText: String = ""
    @State private var replyTargetName: String?
    @State private var replyParentId: Int?
    @State private var isPosting = false
    @State private var commentItems: [ChallengeComment]
    @State private var currentPage = 1
    @State private var hasMore = true
    @State private var isLoadingMore = false

    init(
        challengeId: Int,
        comments: [ChallengeComment],
        onClose: @escaping () -> Void,
        onLoadMore: ((Int, Int, @escaping ([ChallengeComment], Bool) -> Void) -> Void)? = nil,
        onCommentLike: ((Int, Bool, @escaping (Bool) -> Void) -> Void)? = nil,
        onPostComment: ((Int, String, Int, String?, @escaping (Result<ChallengeComment, Error>) -> Void) -> Void)? = nil,
        onDeleteComment: ((Int, Int, @escaping (Bool) -> Void) -> Void)? = nil
    ) {
        self.challengeId = challengeId
        self.onClose = onClose
        self.onLoadMore = onLoadMore
        self.onCommentLike = onCommentLike
        self.onPostComment = onPostComment
        self.onDeleteComment = onDeleteComment
        _commentItems = State(initialValue: comments)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 16)

            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(commentItems) { comment in
                        CommentRowView(
                            comment: comment,
                            onReply: { targetName, parentId in
                                replyTargetName = targetName
                                replyParentId = parentId
                            },
                            onDelete: {
                                removeComment(comment)
                            },
                            onLike: { commentId, isLiked, completion in
                                onCommentLike?(commentId, isLiked) { success in
                                    if success, let idx = commentItems.firstIndex(where: { $0.commentId == commentId }) {
                                        commentItems[idx].isLiked = isLiked
                                        if isLiked {
                                            commentItems[idx].likeCount += 1
                                        } else {
                                            commentItems[idx].likeCount = max(0, commentItems[idx].likeCount - 1)
                                        }
                                    }
                                    completion(success)
                                }
                            }
                        )
                    }
                    if let onLoadMore = onLoadMore, hasMore {
                        loadMoreTrigger
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }

            Divider()

            inputBar
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
        }
        .background(Color.white)
        .presentationDragIndicator(.visible)
    }
}

private extension ChallengeCommentSheetView {
    var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "bubble.left")
                .font(.system(size: 18))
                .foregroundStyle(Color("5-Text"))

            Text("댓글")
                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .foregroundStyle(Color("5-Text"))

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.gray)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
        }
    }

    var inputBar: some View {
        HStack(spacing: 12) {
            TextField(
                replyPlaceholder,
                text: $inputText,
                prompt: Text(replyPlaceholder)
                    .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(Color.gray)
            )
            .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(Color(.systemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button {
                let content = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !content.isEmpty, !isPosting else { return }
                let parentId = replyParentId ?? 0
                isPosting = true
                let replyToName = replyTargetName
                onPostComment?(challengeId, content, parentId, replyToName) { result in
                    isPosting = false
                    switch result {
                    case .success(let newComment):
                        // 새 댓글 → 댓글 목록 최상단 / 새 대댓글 → 해당 부모의 대댓글 목록 최상단
                        if parentId == 0 {
                            commentItems.insert(newComment, at: 0)
                        } else if let parentIndex = commentItems.firstIndex(where: { $0.commentId == parentId }) {
                            commentItems.insert(newComment, at: parentIndex + 1)
                        } else {
                            commentItems.append(newComment)
                        }
                        inputText = ""
                        replyTargetName = nil
                        replyParentId = nil
                    case .failure:
                        break
                    }
                }
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPosting
                                     ? Color.gray.opacity(0.5)
                                     : Color(.primaryColor55))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPosting)
        }
    }

    var replyPlaceholder: String {
        if let targetName = replyTargetName, !targetName.isEmpty {
            return "\(targetName)님에게 답글 남기기"
        }
        return "회원님의 생각을 남겨보세요."
    }

    var loadMoreTrigger: some View {
        Group {
            if isLoadingMore {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            } else {
                Color.clear
                    .frame(height: 1)
                    .onAppear { loadMoreIfNeeded() }
            }
        }
    }

    func loadMoreIfNeeded() {
        guard hasMore, !isLoadingMore, let onLoadMore = onLoadMore else { return }
        isLoadingMore = true
        onLoadMore(challengeId, currentPage) { newComments, more in
            commentItems.append(contentsOf: newComments)
            hasMore = more
            currentPage += 1
            isLoadingMore = false
        }
    }

    func removeComment(_ comment: ChallengeComment) {
        guard let onDeleteComment = onDeleteComment else {
            commentItems.removeAll { $0.commentId == comment.commentId }
            return
        }
        onDeleteComment(challengeId, comment.commentId) { success in
            if success {
                commentItems.removeAll { $0.commentId == comment.commentId }
            }
        }
    }
}

private struct CommentRowView: View {
    let comment: ChallengeComment
    /// (대상 이름, 부모 댓글 ID)
    let onReply: (String, Int) -> Void
    let onDelete: () -> Void
    var onLike: ((Int, Bool, @escaping (Bool) -> Void) -> Void)?

    @State private var isLiked: Bool
    @State private var isShowingDeleteDialog = false

    init(
        comment: ChallengeComment,
        onReply: @escaping (String, Int) -> Void,
        onDelete: @escaping () -> Void,
        onLike: ((Int, Bool, @escaping (Bool) -> Void) -> Void)? = nil
    ) {
        self.comment = comment
        self.onReply = onReply
        self.onDelete = onDelete
        self.onLike = onLike
        _isLiked = State(initialValue: comment.isLiked)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.white)
                )

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(comment.authorName)
                        .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                        .foregroundStyle(Color("5-Text"))

                    Spacer()

                    if comment.isMine {
                        Button {
                            isShowingDeleteDialog = true
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.gray)
                        }
                        .buttonStyle(.plain)
                        .fullScreenCover(isPresented: $isShowingDeleteDialog) {
                            ZStack {
                                CommonPopupView(
                                    isPresented: $isShowingDeleteDialog,
                                    title: "정말로 댓글을 삭제하시겠습니까?",
                                    message: "삭제 시 댓글이 영구적으로 삭제되며, 복구할 수 없습니다.",
                                    leftButtonText: "취소",
                                    rightButtonText: "삭제",
                                    leftAction: { isShowingDeleteDialog = false },
                                    rightAction: {
                                        isShowingDeleteDialog = false
                                        onDelete()
                                    }
                                )
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .presentationBackground(.clear)
                        }
                    } else {
                        Button {
                            let newValue = !isLiked
                            onLike?(comment.commentId, newValue) { success in
                                if success {
                                    isLiked = newValue
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .font(.system(size: 14))
                                    .foregroundStyle(isLiked ? Color(.systemRed) : Color.gray)
                                Text("\(comment.likeCount)")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.gray)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                if let replyToName = comment.replyToName, comment.isReply {
                    Text("\(replyToName)에게 답글")
                        .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                        .foregroundStyle(Color.gray)
                }

                Text(comment.content)
                    .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(Color("5-Text"))

                Button {
                    onReply(comment.authorName, comment.commentId)
                } label: {
                    Text("대댓글 달기")
                        .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                        .foregroundStyle(Color.gray)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.leading, comment.isReply ? 24 : 0)
        .onChange(of: comment.isLiked) { _, newValue in
            isLiked = newValue
        }
    }
}

#Preview {
    ChallengeCommentSheetView(
        challengeId: 1,
        comments: ChallengeComment.sample,
        onClose: {}
    )
    .presentationDetents([.height(520)])
}
