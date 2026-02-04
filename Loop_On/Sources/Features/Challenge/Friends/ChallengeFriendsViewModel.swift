//
//  ChallengeFriendsViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 1/22/26.
//

import Foundation

final class ChallengeFriendsViewModel: ObservableObject {
    @Published var friends: [ChallengeFriend]
    @Published var searchText: String = ""
    @Published var hasPendingRequests: Bool
    @Published var friendRequests: [ChallengeFriendRequest]
    @Published var isShowingRequestSheet: Bool = false

    init(
        friends: [ChallengeFriend] = ChallengeFriend.sampleFriends,
        hasPendingRequests: Bool = true,
        friendRequests: [ChallengeFriendRequest] = ChallengeFriendRequest.sampleRequests
    ) {
        self.friends = friends
        self.hasPendingRequests = hasPendingRequests
        self.friendRequests = friendRequests
    }

    var filteredFriends: [ChallengeFriend] {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return friends }
        return friends.filter {
            $0.name.localizedCaseInsensitiveContains(keyword) ||
            $0.subtitle.localizedCaseInsensitiveContains(keyword)
        }
    }

    func removeFriend(id: UUID) {
        // TODO: API 연결 시 친구 삭제 요청 처리 (id)
        friends.removeAll { $0.id == id }
    }

    func openRequestList() {
        // TODO: API 연결 시 친구 요청 목록 모달/화면 이동 처리
        isShowingRequestSheet = true
    }

    func acceptRequest(id: UUID) {
        // TODO: API 연결 시 친구 요청 수락 처리 (id)
        friendRequests.removeAll { $0.id == id }
        updatePendingState()
    }

    func rejectRequest(id: UUID) {
        // TODO: API 연결 시 친구 요청 거절 처리 (id)
        friendRequests.removeAll { $0.id == id }
        updatePendingState()
    }

    func acceptAllRequests() {
        // TODO: API 연결 시 친구 요청 전체 수락 처리
        friendRequests.removeAll()
        updatePendingState()
    }

    func rejectAllRequests() {
        // TODO: API 연결 시 친구 요청 전체 거절 처리
        friendRequests.removeAll()
        updatePendingState()
    }

    func closeRequestSheet() {
        isShowingRequestSheet = false
    }

    private func updatePendingState() {
        hasPendingRequests = !friendRequests.isEmpty
    }
}
