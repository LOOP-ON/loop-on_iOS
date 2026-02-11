//
//  ChallengeComment.swift
//  Loop_On
//
//  Created by 김세은 on 2/4/26.
//

import Foundation

struct ChallengeComment: Identifiable {
    var id: Int { commentId }
    let commentId: Int
    let authorName: String
    let content: String
    let isReply: Bool
    let replyToName: String?
    let isMine: Bool
    var isLiked: Bool
    var likeCount: Int
}

extension ChallengeComment {
    static let sample: [ChallengeComment] = [
        ChallengeComment(
            commentId: 0,
            authorName: "서리",
            content: "댓글 내용!!!!",
            isReply: false,
            replyToName: nil,
            isMine: true,
            isLiked: false,
            likeCount: 0
        ),
        ChallengeComment(
            commentId: 1,
            authorName: "주디",
            content: "댓글 내용!!!!",
            isReply: false,
            replyToName: nil,
            isMine: false,
            isLiked: true,
            likeCount: 1
        ),
        ChallengeComment(
            commentId: 2,
            authorName: "주디",
            content: "댓글 내용!!!!",
            isReply: false,
            replyToName: nil,
            isMine: false,
            isLiked: false,
            likeCount: 0
        ),
        ChallengeComment(
            commentId: 3,
            authorName: "서리",
            content: "대댓글 예시입니다.",
            isReply: true,
            replyToName: "주디",
            isMine: true,
            isLiked: false,
            likeCount: 0
        ),
        ChallengeComment(
            commentId: 4,
            authorName: "주디",
            content: "댓글 내용!!!!",
            isReply: false,
            replyToName: nil,
            isMine: false,
            isLiked: false,
            likeCount: 0
        )
    ]
}
