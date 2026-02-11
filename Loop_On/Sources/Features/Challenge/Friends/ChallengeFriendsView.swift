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
    private let shouldLoadOnAppear: Bool

    init(
        viewModel: ChallengeFriendsViewModel = ChallengeFriendsViewModel(),
        shouldLoadOnAppear: Bool = true
    ) {
        self.viewModel = viewModel
        self.shouldLoadOnAppear = shouldLoadOnAppear
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 12) {
                searchBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        if viewModel.isShowingSearchResults {
                            if viewModel.searchResults.isEmpty {
                                emptySearchState(message: viewModel.searchErrorMessage)
                                    .padding(.top, 24)
                            } else {
                                ForEach(viewModel.searchResults) { result in
                                    ChallengeFriendSearchRow(
                                        result: result,
                                        onRequest: { userId in
                                            viewModel.sendFriendRequest(userId: userId)
                                        }
                                    )
                                }
                            }
                        } else {
                            if viewModel.filteredFriends.isEmpty {
                                emptyFriendsState(message: viewModel.loadFriendsErrorMessage)
                                    .padding(.top, 24)
                            } else {
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
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    viewModel.refreshFriends()
                }
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
        .tint(Color(.primaryColorVarient65))
        .alert(
            "안내",
            isPresented: $viewModel.isShowingSearchAlert
        ) {
            Button("확인") {}
        } message: {
            Text(viewModel.searchAlertMessage ?? "")
        }
        .onAppear {
            if shouldLoadOnAppear {
                viewModel.loadFriendsIfNeeded()
            }
        }
        .onChange(of: viewModel.searchText) { _, newValue in
            if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                viewModel.clearSearchResults()
            }
        }
    }
}

private extension ChallengeFriendsView {
    var searchBar: some View {
        HStack(spacing: 8) {
            TextField("검색", text: $viewModel.searchText)
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(Color.black)
                .submitLabel(.search)
                .onSubmit {
                    viewModel.searchFriends()
                }

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                    viewModel.clearSearchResults()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.gray.opacity(0.6))
                }
                .buttonStyle(.plain)
            }

            Button {
                viewModel.searchFriends()
            } label: {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.gray)
            }
            .buttonStyle(.plain)
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

    func emptyFriendsState(message: String?) -> some View {
        let title = message == nil ? "아직 친구가 없어요" : "목록을 불러오지 못했어요"
        let detail = message ?? "친구를 추가하고 여정을 함께 시작해보세요."
        return VStack(spacing: 8) {
            Text(title)
                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .foregroundStyle(Color("5-Text"))

            Text(detail)
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(Color.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    func emptySearchState(message: String?) -> some View {
        let title = message == nil ? "검색 결과가 없어요" : "목록을 불러오지 못했어요"
        let detail = message ?? "다른 키워드로 다시 검색해 보세요."
        return VStack(spacing: 8) {
            Text(title)
                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .foregroundStyle(Color("5-Text"))

            Text(detail)
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(Color.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

private struct ChallengeFriendRow: View {
    let friend: ChallengeFriend
    var onDelete: (Int) -> Void

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

private struct ChallengeFriendSearchRow: View {
    let result: ChallengeFriendSearchResult
    var onRequest: (Int) -> Void

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
                Text(result.nickname)
                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .foregroundStyle(Color("5-Text"))

                Text(result.bio)
                    .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(Color.gray)
            }

            Spacer()

            Button {
                onRequest(result.id)
            } label: {
                Text(result.isRequestSent ? "신청됨" : "신청")
                    .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.primaryColorVarient65))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }
}

#Preview("Empty") {
    let emptyViewModel = ChallengeFriendsViewModel(
        friends: [],
        hasPendingRequests: false,
        friendRequests: []
    )
    return ChallengeFriendsView(viewModel: emptyViewModel, shouldLoadOnAppear: false)
}

#Preview("Load Error") {
    let errorViewModel = ChallengeFriendsViewModel(
        friends: [],
        hasPendingRequests: false,
        friendRequests: []
    )
    errorViewModel.loadFriendsErrorMessage = "네트워크 상태를 확인한 뒤 다시 시도해 주세요.\n같은 현상이 지속될 경우 문의해 주세요."
    return ChallengeFriendsView(viewModel: errorViewModel, shouldLoadOnAppear: false)
}
