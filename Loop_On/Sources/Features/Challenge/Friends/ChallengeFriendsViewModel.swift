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
    @Published var searchResults: [ChallengeFriendSearchResult] = []
    @Published var hasSearched: Bool = false
    @Published var isSearching: Bool = false
    @Published var searchErrorMessage: String?
    @Published var isShowingSearchAlert: Bool = false
    @Published var searchAlertMessage: String?

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

    var isShowingSearchResults: Bool {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return hasSearched && !keyword.isEmpty
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

    func clearSearchResults() {
        hasSearched = false
        searchResults = []
        searchErrorMessage = nil
    }

    func searchFriends() {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else {
            clearSearchResults()
            return
        }

        hasSearched = true
        isSearching = true
        searchErrorMessage = nil

        networkManager.request(
            target: .searchFriends(query: keyword, page: 0, size: 20),
            decodingType: ChallengeFriendSearchPageDTO.self
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isSearching = false
                switch result {
                case .success(let page):
                    self.searchResults = page.content.map { ChallengeFriendSearchResult(dto: $0) }
                case .failure(let error):
                    // TODO: API 연결 시 친구 검색 실패 처리 (에러 메시지 노출 등)
                    print("❌ [Friends] searchFriends failed: \(error)")
                    self.searchResults = []
                    self.searchErrorMessage = "검색 결과를 불러오지 못했어요.\n네트워크 상태를 확인해 주세요."
                }
            }
        }
    }

    func sendFriendRequest(userId: Int) {
        guard let index = searchResults.firstIndex(where: { $0.id == userId }) else { return }
        if searchResults[index].isRequestSent {
            searchAlertMessage = "이미 친구 신청을 보냈습니다."
            isShowingSearchAlert = true
            return
        }

        let request = FriendRequestSendRequest(receiverId: userId)
        print("✅ [Friends] sendFriendRequest start: POST /api/friend-request/send body={receiverId:\(userId)}")
        networkManager.request(
            target: .sendFriendRequest(request: request),
            decodingType: FriendRequestSendResponse.self
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case .success(let response):
                    print("✅ [Friends] sendFriendRequest success")
                    let nickname = self.searchResults[index].nickname
                    self.searchResults[index].isRequestSent = true
                    self.searchAlertMessage = "'\(nickname)'에게 친구 신청을 보냈습니다."
                    self.isShowingSearchAlert = true
                case .failure(let error):
                    // TODO: API 연결 시 친구 신청 실패 처리 (에러 메시지 노출 등)
                    print("❌ [Friends] sendFriendRequest failed: \(error)")
                    if case let .serverError(_, message) = error,
                       message.contains("이미 대기 중인 친구 요청") {
                        self.searchResults[index].isRequestSent = true
                        self.searchAlertMessage = "이미 친구 신청을 보냈습니다."
                    } else {
                        self.searchAlertMessage = "친구 신청을 보내지 못했어요.\n잠시 후 다시 시도해 주세요."
                    }
                    self.isShowingSearchAlert = true
                }
            }
        }
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
