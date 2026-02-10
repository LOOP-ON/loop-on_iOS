//
//  PersonalFeedDetailView.swift
//  Loop_On
//
//  개인 화면 그리드에서 썸네일 탭 시 열리는 피드 상세.
//  선택한 피드가 최상단에 오고, 위로 스크롤 = 더 최신, 아래로 스크롤 = 더 이전.
//

import SwiftUI

struct PersonalFeedDetailView: View {
    /// 내 챌린지 목록 (API 순서 = 최신순, index 0이 최신)
    let items: [MyChallengeItemDTO]
    /// 그리드에서 선택한 인덱스 → 이 피드가 화면 최상단에 위치
    let selectedIndex: Int
    let onClose: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                                feedCard(item: item)
                                    .id(index)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                    .scrollIndicators(.hidden)
                    .onAppear {
                        let target = min(selectedIndex, items.count - 1)
                        if target >= 0 {
                            proxy.scrollTo(target, anchor: .top)
                        }
                    }
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 0) {
            Button {
                onClose()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color("5-Text"))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 164, height: 40)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(Color(.systemGroupedBackground))
    }

    private func feedCard(item: MyChallengeItemDTO) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)

            if let url = URL(string: item.imageUrl), !item.imageUrl.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure, .empty:
                        placeholderView
                    @unknown default:
                        placeholderView
                    }
                }
                .frame(minHeight: 320)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                placeholderView
                    .frame(minHeight: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.gray.opacity(0.15))
            .overlay(
                Image(systemName: "mountain.2")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.gray.opacity(0.5))
            )
    }
}

#Preview {
    PersonalFeedDetailView(
        items: (0..<6).map { MyChallengeItemDTO(challengeId: $0 + 1, imageUrl: "") },
        selectedIndex: 2,
        onClose: {}
    )
}
