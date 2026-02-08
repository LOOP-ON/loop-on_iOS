//
//  ChallengeFriendsViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 1/22/26.
//

import Foundation

final class ChallengeFriendsViewModel: ObservableObject {
    private let networkManager: DefaultNetworkManager<FriendsAPI>
    private var hasLoadedFriends = false

    @Published var friends: [ChallengeFriend]
    @Published var searchText: String = ""
    @Published var hasPendingRequests: Bool
    @Published var friendRequests: [ChallengeFriendRequest]
    @Published var isShowingRequestSheet: Bool = false
    @Published var isLoadingFriends: Bool = false
    @Published var loadFriendsErrorMessage: String?

    init(
        friends: [ChallengeFriend] = [],
        hasPendingRequests: Bool = true,
        friendRequests: [ChallengeFriendRequest] = ChallengeFriendRequest.sampleRequests,
        networkManager: DefaultNetworkManager<FriendsAPI> = DefaultNetworkManager<FriendsAPI>()
    ) {
        self.friends = friends
        self.hasPendingRequests = hasPendingRequests
        self.friendRequests = friendRequests
        self.networkManager = networkManager
    }

    var filteredFriends: [ChallengeFriend] {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return friends }
        return friends.filter {
            $0.name.localizedCaseInsensitiveContains(keyword) ||
            $0.subtitle.localizedCaseInsensitiveContains(keyword)
        }
    }

    func removeFriend(id: Int) {
        // TODO: API 연결 시 친구 삭제 요청 처리 (id)
        friends.removeAll { $0.id == id }
    }

    func loadFriendsIfNeeded() {
        guard !hasLoadedFriends else { return }
        loadFriends()
    }

    func refreshFriends() {
        hasLoadedFriends = false
        loadFriends()
    }

    func loadFriends() {
        print("✅ [Friends] loadFriends request start: GET /api/friend")
        isLoadingFriends = true
        networkManager.request(
            target: .getFriends,
            decodingType: [ChallengeFriendListItemDTO].self
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isLoadingFriends = false
                self.hasLoadedFriends = true

                switch result {
                case .success(let items):
                    self.loadFriendsErrorMessage = nil
                    print("✅ [Friends] loadFriends success: count=\(items.count)")
                    self.friends = items.map { ChallengeFriend(dto: $0) }
                case .failure(let error):
                    // TODO: API 연결 시 친구 목록 실패 처리 (에러 메시지 노출 등)
                    print("❌ [Friends] loadFriends failed: \(error)")
                    self.loadFriendsErrorMessage = "네트워크 상태를 확인한 뒤 다시 시도해 주세요.\n같은 현상이 지속될 경우 문의해 주세요."
                }
            }
        }
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
