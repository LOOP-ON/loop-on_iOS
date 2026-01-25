//
//  ChallengeFriendsView.swift
//  Loop_On
//
//  Created by 이경민 on 1/22/26.
//

import SwiftUI

struct ChallengeFriendsView: View {
    @ObservedObject var viewModel: ChallengeFriendsViewModel
    @State private var pendingDeleteFriend: ChallengeFriend?
    @State private var isShowingDeleteAlert = false

    init(viewModel: ChallengeFriendsViewModel = ChallengeFriendsViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 12) {
                searchBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredFriends) { friend in
                            ChallengeFriendRow(
                                friend: friend,
                                onDelete: { friendId in
                                    pendingDeleteFriend = viewModel.friends.first { $0.id == friendId }
                                    isShowingDeleteAlert = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120)
                }
                .scrollIndicators(.hidden)
            }

            requestButton
                .padding(.trailing, 20)
                .padding(.bottom, 30 + safeAreaBottomHeight)
        }
        .alert(
            deleteAlertTitle,
            isPresented: $isShowingDeleteAlert
        ) {
            Button("취소", role: .cancel) {
                pendingDeleteFriend = nil
            }
            Button("친구 삭제", role: .destructive) {
                if let friendId = pendingDeleteFriend?.id {
                    viewModel.removeFriend(id: friendId)
                }
                pendingDeleteFriend = nil
            }
        }
        .tint(Color(.primaryColor55))
    }
}

private extension ChallengeFriendsView {
    var searchBar: some View {
        HStack(spacing: 8) {
            TextField("검색", text: $viewModel.searchText)
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(Color.black)

            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.gray)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }

    var requestButton: some View {
        Button(action: viewModel.openRequestList) {
            ZStack {
                let isActive = viewModel.hasPendingRequests
                Circle()
                    .fill(isActive ? Color(.primaryColorVarient65) : Color.gray.opacity(0.3))
                    .frame(width: 52, height: 52)
                    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)

                Image(systemName: "bell")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.white)
            }
            .overlay(alignment: .topTrailing) {
                if viewModel.hasPendingRequests {
                    Circle()
                        .fill(Color(.systemRed))
                        .frame(width: 10, height: 10)
                        .offset(x: 4, y: -4)
                }
            }
        }
        .buttonStyle(.plain)
    }

    var safeAreaBottomHeight: CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        return window?.safeAreaInsets.bottom ?? 0
    }

    var deleteAlertTitle: String {
        let name = pendingDeleteFriend?.name ?? "친구"
        return "정말로 '\(name)'을(를) 친구 목록에서 삭제할까요?"
    }
}

private struct ChallengeFriendRow: View {
    let friend: ChallengeFriend
    var onDelete: (UUID) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundStyle(Color.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .foregroundStyle(Color("5-Text"))

                Text(friend.subtitle)
                    .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(Color.gray)
            }

            Spacer()

            if !friend.isSelf {
                Button {
                    onDelete(friend.id)
                } label: {
                    Text("삭제")
                        .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemRed).opacity(0.85))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    ChallengeFriendsView(viewModel: ChallengeFriendsViewModel())
}
