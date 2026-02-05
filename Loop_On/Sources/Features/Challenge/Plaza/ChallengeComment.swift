//
//  ChallengeComment.swift
//  Loop_On
//
//  Created by 김세은 on 2/4/26.
//

import Foundation

struct ChallengeComment: Identifiable {
    let id = UUID()
    let authorName: String
    let content: String
    let isReply: Bool
    let replyToName: String?
    let isMine: Bool
    var isLiked: Bool
}

extension ChallengeComment {
    static let sample: [ChallengeComment] = [
        ChallengeComment(
            authorName: "서리",
            content: "댓글 내용!!!!",
            isReply: false,
            replyToName: nil,
            isMine: true,
            isLiked: false
        ),
        ChallengeComment(
            authorName: "주디",
            content: "댓글 내용!!!!",
            isReply: false,
            replyToName: nil,
            isMine: false,
            isLiked: true
        ),
        ChallengeComment(
            authorName: "주디",
            content: "댓글 내용!!!!",
            isReply: false,
            replyToName: nil,
            isMine: false,
            isLiked: false
        ),
        ChallengeComment(
            authorName: "서리",
            content: "대댓글 예시입니다.",
            isReply: true,
            replyToName: "주디",
            isMine: true,
            isLiked: false
        ),
        ChallengeComment(
            authorName: "주디",
            content: "댓글 내용!!!!",
            isReply: false,
            replyToName: nil,
            isMine: false,
            isLiked: false
        )
    ]
}
