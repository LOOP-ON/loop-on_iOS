//
//  ChallengeCardView.swift
//  Loop_On
//
//  Created by 김세은 on 1/22/26.
//

import SwiftUI

struct ChallengeCardView: View {
    @Environment(NavigationRouter.self) private var router
    @Binding var card: ChallengeCard
    var onLikeTap: ((Int, Bool) -> Void)?
    var onEdit: ((Int) -> Void)?
    /// 삭제 확정 시 호출되는 콜백 (팝업에서 최종 확정 후 호출)
    var onDelete: ((Int) -> Void)?
    var onCommentTap: ((Int, @escaping ([ChallengeComment]) -> Void) -> Void)?
    /// (challengeId, page, completion(추가 댓글, hasMore))
    var onLoadMoreComments: ((Int, Int, @escaping ([ChallengeComment], Bool) -> Void) -> Void)?
    /// (commentId, isLiked, completion(success))
    var onCommentLike: ((Int, Bool, @escaping (Bool) -> Void) -> Void)?
    /// (challengeId, content, parentId, replyToName?, completion(새 댓글 또는 에러))
    var onPostComment: ((Int, String, Int, String?, @escaping (Result<ChallengeComment, Error>) -> Void) -> Void)?
    /// (challengeId, commentId, completion(success))
    var onDeleteComment: ((Int, Int, @escaping (Bool) -> Void) -> Void)?
    /// 타인 프로필 열기 (제공 시 오버레이로 열어 탭바 유지)
    var onOpenOtherProfile: ((String) -> Void)? = nil
    @State private var isShowingMenu = false
    @State private var isShowingCommentSheet = false
    @State private var comments: [ChallengeComment] = []

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(card.title)
                        .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                        .foregroundStyle(Color("5-Text"))

                    Spacer()

                    if card.isMine {
                        Button {
                            isShowingMenu.toggle()
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundStyle(Color.gray)
                                .padding(4)
                        }
                        .buttonStyle(.plain)
                    }
                }

                imageCarousel

                Text(card.subtitle)
                    .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(Color.black)

                FlowLayout(items: card.hashtags) { tag in
                    Text(tag)
                        .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color(.primaryColorVarient95))
                        )
                        .foregroundStyle(Color(.primaryColor55))
                }

                Text(card.dateText)
                    .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                    .foregroundStyle(Color.gray)

                HStack(spacing: 8) {
                    Button {
                        if let onOpenOtherProfile = onOpenOtherProfile {
                            onOpenOtherProfile(card.authorName)
                        } else {
                            router.push(.app(.profile(nickname: card.authorName)))
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if let urlString = card.profileImageUrl,
                               !urlString.isEmpty,
                               let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 14))
                                                .foregroundStyle(Color.white)
                                        )
                                }
                                .frame(width: 28, height: 28)
                                .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 14))
                                            .foregroundStyle(Color.white)
                                    )
                            }

                            Text(card.authorName)
                                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    HStack(spacing: 16) {
                        Button {
                            if onCommentTap != nil {
                                isShowingCommentSheet = true
                            } else {
                                comments = ChallengeComment.sample
                                isShowingCommentSheet = true
                            }
                        } label: {
                            Image(systemName: "bubble.left")
                                .foregroundStyle(Color.gray)
                        }
                        .buttonStyle(.plain)
                        Button {
                            card.isLiked.toggle()
                            onLikeTap?(card.challengeId, card.isLiked)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: card.isLiked ? "heart.fill" : "heart")
                                    .foregroundStyle(card.isLiked ? Color(.systemRed) : Color.gray)
                                Text("\(card.likeCount)")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.gray)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .font(.system(size: 16))
                    .foregroundStyle(Color.gray)
                }
            }

            if isShowingMenu {
                cardMenu
                    .padding(.top, 28)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        .sheet(isPresented: $isShowingCommentSheet) {
            ChallengeCommentSheetView(
                challengeId: card.challengeId,
                comments: onCommentTap == nil ? comments : [],
                onLoadComments: onCommentTap,
                onClose: { isShowingCommentSheet = false },
                onLoadMore: onLoadMoreComments,
                onCommentLike: onCommentLike,
                onPostComment: onPostComment,
                onDeleteComment: onDeleteComment
            )
            .presentationDetents([.height(520), .large])
        }
    }

    private var imageCarousel: some View {
        let count = max(1, card.imageCount)
        let pages = Array(0..<count).chunked(into: 3)
        let spacing: CGFloat = 8

        return GeometryReader { proxy in
            let side = (proxy.size.width - spacing * 2) / 3

            TabView {
                ForEach(pages.indices, id: \.self) { pageIndex in
                    HStack(spacing: spacing) {
                        ForEach(pages[pageIndex], id: \.self) { globalIdx in
                            Group {
                                if globalIdx < card.imageUrls.count, let url = URL(string: card.imageUrls[globalIdx]) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        case .failure:
                                            placeholderImage(side: side)
                                        case .empty:
                                            placeholderImage(side: side)
                                        @unknown default:
                                            placeholderImage(side: side)
                                        }
                                    }
                                } else {
                                    placeholderImage(side: side)
                                }
                            }
                            .frame(width: side, height: side)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .frame(height: 110)
    }

    private func placeholderImage(side: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.15))
            .frame(width: side, height: side)
            .overlay(
                Image(systemName: "photo")
                    .foregroundStyle(Color.gray.opacity(0.6))
            )
    }

    private var cardMenu: some View {
        VStack(spacing: 0) {
            Button {
                isShowingMenu = false
                // TODO: API 연결 시 게시물 수정 처리 (card.id)
                onEdit?(card.challengeId)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16))
                    Text("게시물 수정")
                        .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                    Spacer()
                }
                .foregroundStyle(Color("5-Text"))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)

            Divider()
                .background(Color.gray.opacity(0.2))

            Button {
                // 메뉴를 닫고 상위 뷰에 삭제 요청 전달 (팝업은 상위 뷰에서 처리)
                isShowingMenu = false
                onDelete?(card.challengeId)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                    Text("게시물 삭제")
                        .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                    Spacer()
                }
                .foregroundStyle(Color("5-Text"))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
        }
        .frame(width: 180)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    VStack(spacing: 16) {
        ChallengeCardView(
            card: .constant(
                ChallengeCard(
                    challengeId: 1,
                    title: "세 번째 여정",
                    subtitle: "2026 갓생 살기 성공 🍀",
                    dateText: "2026.01.01",
                    hashtags: ["#생활루틴", "#갓생", "#2026"],
                    authorName: "서리",
                    imageUrls: [],
                    profileImageUrl: nil,
                    isLiked: false,
                    likeCount: 0
                )
            )
        )

        ChallengeCardView(
            card: .constant(
                ChallengeCard(
                    challengeId: 2,
                    title: "네 번째 여정",
                    subtitle: "하루 루틴 완주",
                    dateText: "2026.01.02",
                    hashtags: ["#아침루틴", "#습관"],
                    authorName: "민지",
                    imageUrls: [],
                    profileImageUrl: nil,
                    isLiked: true,
                    likeCount: 5
                )
            )
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
    .environment(NavigationRouter())
}
