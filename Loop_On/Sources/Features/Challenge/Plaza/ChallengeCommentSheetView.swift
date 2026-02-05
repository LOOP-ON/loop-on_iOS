//
//  ChallengeCommentSheetView.swift
//  Loop_On
//
//  Created by 김세은 on 2/4/26.
//

import SwiftUI

struct ChallengeCommentSheetView: View {
    let onClose: () -> Void

    @State private var inputText: String = ""
    @State private var replyTargetName: String?
    @State private var commentItems: [ChallengeComment]

    init(comments: [ChallengeComment], onClose: @escaping () -> Void) {
        self.onClose = onClose
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
                            onReply: { targetName in
                                replyTargetName = targetName
                            },
                            onDelete: {
                                removeComment(comment)
                            }
                        )
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
                // TODO: API 연결 시 댓글/대댓글 등록 요청 처리
                inputText = ""
                replyTargetName = nil
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                     ? Color.gray.opacity(0.5)
                                     : Color(.primaryColor55))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    var replyPlaceholder: String {
        if let targetName = replyTargetName, !targetName.isEmpty {
            return "\(targetName)님에게 답글 남기기"
        }
        return "회원님의 생각을 남겨보세요."
    }

    func removeComment(_ comment: ChallengeComment) {
        // TODO: API 연결 시 댓글 삭제 요청 처리 (comment.id)
        if comment.isReply {
            commentItems.removeAll { $0.id == comment.id }
        } else {
            commentItems.removeAll { item in
                item.id == comment.id || (item.isReply && item.replyToName == comment.authorName)
            }
        }
    }
}

private struct CommentRowView: View {
    let comment: ChallengeComment
    let onReply: (String) -> Void
    let onDelete: () -> Void

    @State private var isLiked: Bool
    @State private var isShowingDeleteDialog = false

    init(
        comment: ChallengeComment,
        onReply: @escaping (String) -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.comment = comment
        self.onReply = onReply
        self.onDelete = onDelete
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
                        .confirmationDialog(
                            "댓글 옵션",
                            isPresented: $isShowingDeleteDialog,
                            titleVisibility: .hidden
                        ) {
                            Button("댓글 삭제", role: .destructive) {
                                // TODO: API 연결 시 댓글 삭제 요청 처리 (comment.id)
                                onDelete()
                            }
                            Button("취소", role: .cancel) { }
                        }
                    } else {
                        Button {
                            isLiked.toggle()
                            // TODO: 댓글 좋아요/취소 API 연결
                        } label: {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 14))
                                .foregroundStyle(isLiked ? Color(.systemRed) : Color.gray)
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
                    // TODO: API 연결 시 대댓글 작성 흐름 진입 처리 (comment.id)
                    onReply(comment.authorName)
                } label: {
                    Text("대댓글 달기")
                        .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                        .foregroundStyle(Color.gray)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.leading, comment.isReply ? 24 : 0)
    }
}

#Preview {
    ChallengeCommentSheetView(
        comments: ChallengeComment.sample,
        onClose: {}
    )
    .presentationDetents([.height(520)])
}
