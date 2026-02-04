//
//  ChallengeCardView.swift
//  Loop_On
//
//  Created by 이경민 on 1/22/26.
//

import SwiftUI

struct ChallengeCardView: View {
    @Binding var card: ChallengeCard
    var onLikeTap: ((UUID, Bool) -> Void)?
    var onEdit: ((UUID) -> Void)?
    var onDelete: ((UUID) -> Void)?
    @State private var isShowingMenu = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(card.title)
                        .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                        .foregroundStyle(Color("5-Text"))

                    Spacer()

                    Button {
                        isShowingMenu.toggle()
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(Color.gray)
                            .padding(4)
                    }
                    .buttonStyle(.plain)
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
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.white)
                        )

                    Text(card.authorName)
                        .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 14))

                    Spacer()

                    HStack(spacing: 16) {
                        Image(systemName: "bubble.left")
                        Button {
                            card.isLiked.toggle()
                            // TODO: API 연결 시 좋아요/취소 요청 트리거
                            onLikeTap?(card.id, card.isLiked)
                        } label: {
                            Image(systemName: card.isLiked ? "heart.fill" : "heart")
                                .foregroundStyle(card.isLiked ? Color(.systemRed) : Color.gray)
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
        .overlay {
            if isShowingMenu {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isShowingMenu = false
                    }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
    }

    private var imageCarousel: some View {
        let pages = Array(repeating: "photo", count: card.imageCount).chunked(into: 3)
        let spacing: CGFloat = 8

        return GeometryReader { proxy in
            let side = (proxy.size.width - spacing * 2) / 3

            TabView {
                ForEach(pages.indices, id: \.self) { index in
                    HStack(spacing: spacing) {
                        ForEach(pages[index].indices, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: side, height: side)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundStyle(Color.gray.opacity(0.6))
                                )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .frame(height: 110)
    }

    private var cardMenu: some View {
        VStack(spacing: 0) {
            Button {
                isShowingMenu = false
                // TODO: API 연결 시 게시물 수정 처리 (card.id)
                onEdit?(card.id)
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
                isShowingMenu = false
                // TODO: API 연결 시 게시물 삭제 처리 (card.id)
                onDelete?(card.id)
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
                    title: "세 번째 여정",
                    subtitle: "2026 갓생 살기 성공 🍀",
                    dateText: "2026.01.01",
                    hashtags: ["#생활루틴", "#갓생", "#2026"],
                    authorName: "서리",
                    imageCount: 6,
                    isLiked: false
                )
            )
        )

        ChallengeCardView(
            card: .constant(
                ChallengeCard(
                    title: "네 번째 여정",
                    subtitle: "하루 루틴 완주",
                    dateText: "2026.01.02",
                    hashtags: ["#아침루틴", "#습관"],
                    authorName: "민지",
                    imageCount: 3,
                    isLiked: true
                )
            )
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
