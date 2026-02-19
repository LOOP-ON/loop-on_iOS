//
//  PersonalProfileViewModel.swift
//  Loop_On
//
//  Created by Auto on 1/15/26.
//

import Foundation
import SwiftUI
import Moya

// MARK: - ViewModel

@MainActor
final class PersonalProfileViewModel: ObservableObject {
    @Published var user: UserModel?
    @Published var isLoading: Bool = false
    @Published var isUploadingImage: Bool = false
    @Published var errorMessage: String?
    @Published var isFriendRequestSent: Bool = false
    @Published var isFriend: Bool = false

    /// 개인이 올린 챌린지 이미지 URL 목록 (GET /api/challenges/users/me 연동)
    @Published var challengeImages: [String] = []
    /// 내 챌린지 전체 (challengeId + imageUrl). 그리드에서 탭 시 피드 상세용. API 순서 = 최신순(인덱스 0이 최신)
    @Published var myChallengeItems: [MyChallengeItemDTO] = []

    private let challengeNetworkManager = DefaultNetworkManager<ChallengeAPI>()
    private let profileNetworkManager = DefaultNetworkManager<ProfileAPI>(
        plugins: [NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))]
    )
    private let friendsNetworkManager = DefaultNetworkManager<FriendsAPI>(
        plugins: [NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))]
    )
    
    // 내 챌린지 피드 페이지네이션 상태
    private var myChallengesPage: Int = 0
    private let myChallengesPageSize: Int = 20
    private var isLoadingMyChallenges: Bool = false
    private var hasMoreMyChallenges: Bool = true

    private var targetNickname: String?

    // 프로필 정보 수정을 위한 현재 데이터 저장
    private var currentNickname: String = ""
    private var currentBio: String = ""
    private var currentStatusMessage: String = ""

    init(nickname: String? = nil, isRequestSent: Bool = false) {
        self.targetNickname = nickname
        self.isFriendRequestSent = isRequestSent
        // 내비게이션 바 등을 위해 초반엔 빈 모델 혹은 로딩 상태
        // 여기선 빈 유저 모델로 시작하고, loadProfile()에서 채워넣음.
        self.user = nil
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleFriendRequestSent(_:)), name: .challengeFriendRequestSent, object: nil)
        loadProfile()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func loadProfile() {
        isLoading = true
        errorMessage = nil

        let target: ProfileAPI
        if let nickname = targetNickname {
            print("🔍 [loadProfile] 타인 프로필: nickname=\(nickname)")
            target = .getUser(nickname: nickname, page: 0, size: 20, sort: ["createdAt,desc"])
        } else {
            print("🔍 [loadProfile] 내 프로필 (getMe)")
            target = .getMe(page: 0, size: 20, sort: ["createdAt,desc"])
        }

        profileNetworkManager.request(
            target: target,
            decodingType: UserMeResponseDTO.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let profile):
                    let nickname = profile.nickname.trimmingCharacters(in: .whitespacesAndNewlines)
                    let bio = profile.bio?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    let statusMessage = profile.statusMessage?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    
                    // 수정용 데이터 저장
                    self.currentNickname = nickname
                    self.currentBio = bio
                    self.currentStatusMessage = statusMessage
                    
                    print("✅ [Profile] 연동 성공: 닉네임(\(nickname))")
                    
                    self.isFriend = profile.isFriend ?? false
                    
                    let composedBio = [bio, statusMessage]
                        .filter { !$0.isEmpty }
                        .joined(separator: "\n")
                        
                    self.user = UserModel(
                        id: String(profile.userId),
                        name: nickname.isEmpty ? "사용자" : nickname,
                        profileImageURL: profile.profileImageUrl,
                        bio: composedBio.isEmpty ? "소개가 아직 없어요." : composedBio
                    )

                    print("✅ [loadProfile] 응답 nickname: \(profile.nickname)")

                    // 타인 프로필/내 프로필 공통: thumbnailResponse가 있으면 그걸 사용
                    if let thumbPage = profile.thumbnailResponse {
                        let newItems = thumbPage.content.map {
                            MyChallengeItemDTO(challengeId: $0.challengeId, imageUrl: $0.repImageUrl)
                        }
                        print("📸 [loadProfile] thumbnails: \(newItems.count)개, last: \(thumbPage.last ?? false)")
                        for item in newItems {
                            print("  ↪ challengeId=\(item.challengeId), url=\(item.imageUrl)")
                        }
                        
                        // 첫 로딩이므로 리셋
                        self.myChallengeItems = newItems
                        self.challengeImages = newItems.map(\.imageUrl)
                        
                        // 페이징 초기화
                        self.myChallengesPage = 0
                        let isLast = thumbPage.last ?? newItems.isEmpty
                        self.hasMoreMyChallenges = !isLast
                        if !newItems.isEmpty {
                            self.myChallengesPage += 1
                        }
                    } else {
                        // thumbnailResponse가 없으면 (구버전 API 등) 기존 방식 시도 (내 프로필인 경우만 유효)
                        if self.targetNickname == nil {
                            self.loadMyChallenges(reset: true)
                        } else {
                            // 타인 프로필인데 썸네일 없으면 빈 상태
                            self.myChallengeItems = []
                            self.challengeImages = []
                        }
                    }
                    self.isLoading = false

                case .failure(let error):
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    self.user = UserModel(
                        id: "0",
                        name: "사용자",
                        profileImageURL: nil,
                        bio: "프로필을 불러오지 못했어요."
                    )
                    // 실패 시 목록 초기화
                    self.myChallengeItems = []
                    self.challengeImages = []
                    print("❌ [Profile] API failed: \(error)")
                }
            }
        }
    }

    /// 챌린지 목록 더 불러오기 (내 프로필 & 타인 프로필 공용)
    func loadMyChallenges(reset: Bool = false) {
        guard !isLoadingMyChallenges else { return }
        
        if reset {
            myChallengesPage = 0
            hasMoreMyChallenges = true
        } else {
            guard hasMoreMyChallenges else { return }
        }
        
        isLoadingMyChallenges = true
        print("🔄 [loadMyChallenges] targetNickname: \(targetNickname ?? "nil"), page: \(myChallengesPage), reset: \(reset)")
        
        // 내 프로필이면서 기존 방식(별도 API)을 써야 하는 경우 -> getMyChallenges
        // 타인 프로필이거나 내 프로필의 getMe 방식 페이징 -> getUser/getMe 재호출
        
        if let nickname = targetNickname {
            // 타인 프로필: getUser 재호출하여 다음 페이지 썸네일 가져오기
            fetchChallengesViaProfileAPI(target: .getUser(nickname: nickname, page: myChallengesPage, size: myChallengesPageSize, sort: ["createdAt,desc"]), reset: reset)
        } else {
            // 내 프로필: getMe 재호출 (또는 기존 getMyChallenges 사용)
            // 기존 getMyChallenges API가 있다면 그걸 쓰는 게 더 명확할 수 있으나,
            // getMe 응답에 thumbnailResponse가 포함되므로 통일성을 위해 getMe를 쓸 수도 있음.
            // 하지만 기존 코드는 ChallengeAPI.getMyChallenges를 쓰고 있었음.
            // 여기서는 '내 프로필'일 땐 기존 로직 유지를 위해 ChallengeAPI 사용
            
            // 기존 로직 유지 (ChallengeAPI)
            let target = ChallengeAPI.getMyChallenges(
                page: myChallengesPage,
                size: myChallengesPageSize,
                sort: nil
            )
            challengeNetworkManager.request(
                target: target,
                decodingType: MyChallengesPageDTO.self,
                completion: { [weak self] (result: Result<MyChallengesPageDTO, NetworkError>) in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.isLoadingMyChallenges = false
                        switch result {
                        case .success(let page):
                            let newItems = page.content
                            let newImages = newItems.map(\.imageUrl)
                            
                            if reset {
                                self.myChallengeItems = newItems
                                self.challengeImages = newImages
                            } else {
                                self.myChallengeItems.append(contentsOf: newItems)
                                self.challengeImages.append(contentsOf: newImages)
                            }
                            
                            let isLast = page.last ?? newItems.isEmpty
                            self.hasMoreMyChallenges = !isLast
                            
                            if !newItems.isEmpty {
                                self.myChallengesPage += 1
                            }
                        case .failure:
                            if reset {
                                self.myChallengeItems = []
                                self.challengeImages = []
                            }
                        }
                    }
                }
            )
        }
    }
    
    /// 프로필 API를 통해 챌린지(썸네일) 페이징 처리
    private func fetchChallengesViaProfileAPI(target: ProfileAPI, reset: Bool) {
        profileNetworkManager.request(target: target, decodingType: UserMeResponseDTO.self) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoadingMyChallenges = false
                
                switch result {
                case .success(let profile):
                    let thumbPage = profile.thumbnailResponse
                    let newThumbnails = thumbPage?.content ?? []
                    
                    let newItems = newThumbnails.map {
                         MyChallengeItemDTO(challengeId: $0.challengeId, imageUrl: $0.repImageUrl)
                    }
                    let newImages = newItems.map(\.imageUrl)
                    
                    if reset {
                        self.myChallengeItems = newItems
                        self.challengeImages = newImages
                    } else {
                        self.myChallengeItems.append(contentsOf: newItems)
                        self.challengeImages.append(contentsOf: newImages)
                    }
                    
                    // 페이징 판단: API 응답의 last 필드 사용
                    let isLast = thumbPage?.last ?? (newItems.isEmpty || newItems.count < self.myChallengesPageSize)
                    if isLast || newItems.isEmpty {
                        self.hasMoreMyChallenges = false
                    } else {
                        self.myChallengesPage += 1
                    }
                    
                case .failure:
                     if reset {
                         self.myChallengeItems = []
                         self.challengeImages = []
                     }
                }
            }
        }
    }
    
    /// 스크롤이 끝에 가까워졌을 때 다음 페이지를 로드
    func loadMoreChallengesIfNeeded(currentIndex: Int) {
        let thresholdIndex = max(challengeImages.count - 4, 0)
        if currentIndex >= thresholdIndex {
            loadMyChallenges(reset: false)
        }
    }

    /// 프로필 이미지 업로드 (1. 파일 업로드 -> 2. 프로필 정보 수정)
    func uploadProfileImage(imageData: Data, completion: @escaping (Bool) -> Void) {
        isUploadingImage = true
        // 1단계: 이미지 파일 업로드
        print("🚀 1단계: 이미지 파일 업로드 시작...")
        profileNetworkManager.request(
            target: .updateProfileImage(imageData: imageData),
            decodingType: String.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let imageUrl):
                    print("✅ 1단계: 이미지 업로드 성공. URL: \(imageUrl)")
                    // 2단계: 프로필 정보 수정 호출
                    self.updateProfileWithImage(url: imageUrl, completion: completion)
                    
                case .failure(let error):
                    print("❌ 1단계: 이미지 업로드 실패: \(error)")
                    self.isUploadingImage = false
                    completion(false)
                }
            }
        }
    }
    
    /// 이미지 URL을 포함하여 프로필 정보 수정 (PATCH /api/users/profile)
    private func updateProfileWithImage(url: String, completion: @escaping (Bool) -> Void) {
        let request = ProfileUpdateRequestDTO(
            nickname: currentNickname,
            bio: currentBio,
            statusMessage: currentStatusMessage,
            profileImageUrl: url,
            visibility: "PUBLIC" // 기본값 설정
        )
        
        print("🚀 2단계: 프로필 정보 수정 요청 시작... (URL: \(url))")
        print("   📦 요청 데이터: 닉네임=\(currentNickname), Bio=\(currentBio)")
        
        profileNetworkManager.request(
            target: .updateUserProfile(request: request),
            decodingType: UserMeResponseDTO.self
        ) { [weak self] result in
             DispatchQueue.main.async {
                 guard let self = self else { return }
                 self.isUploadingImage = false
                 
                 switch result {
                 case .success(let profile):
                     print("✅ 2단계: 프로필 수정 완료! 최종 URL: \(profile.profileImageUrl ?? "nil")")
                     
                     // UI 갱신
                     if let current = self.user {
                         self.user = UserModel(
                            id: current.id,
                            name: current.name,
                            profileImageURL: profile.profileImageUrl,
                            bio: current.bio // Bio 등은 기존 UI 데이터 유지 (또는 profile 값 사용 가능)
                         )
                     }
                     completion(true)
                     
                 case .failure(let error):
                     print("❌ 2단계: 프로필 수정 실패: \(error)")
                     completion(false)
                 }
             }
        }
    }

    func refreshProfile() {
        loadProfile()
    }

    /// 친구 신청 전송 (POST /api/friend-request/send)
    func requestFriend(receiverId: Int, completion: @escaping (Bool, String?) -> Void) {
        let request = FriendRequestSendRequest(receiverId: receiverId)
        
        print("📨 [FriendRequest] ID=\(receiverId)에게 친구 신청 전송 시도...")
        
        friendsNetworkManager.request(
            target: .sendFriendRequest(request: request),
            decodingType: ChallengeFriendRequestSingleActionResponse.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    print("✅ [FriendRequest] 성공! requester=\(response.requesterId ?? -1), receiver=\(response.receiverId ?? -1)")
                    self.isFriendRequestSent = true
                    
                    NotificationCenter.default.post(
                        name: .challengeFriendRequestSent,
                        object: nil,
                        userInfo: ["userId": receiverId]
                    )
                    
                    completion(true, nil)
                    
                case .failure(let error):
                    // 409 "이미 대기 중인 친구 요청" = 이미 신청한 상태 → UI를 '신청됨'으로 표시 + 알럿
                    if case let .serverError(statusCode, message) = error,
                       statusCode == 409,
                       message.contains("대기 중인 친구 요청") {
                        print("📨 [FriendRequest] 이미 대기 중 → isFriendRequestSent = true + 알럿")
                        self.isFriendRequestSent = true
                        completion(true, "이미 친구 신청을 보냈습니다.")
                    } else {
                        print("❌ [FriendRequest] 실패: \(error)")
                        completion(false, error.localizedDescription)
                    }
                }
            }
        }
    }

    @objc private func handleFriendRequestSent(_ notification: Notification) {
        guard let userId = notification.userInfo?["userId"] as? Int else { return }
        // user.id가 String이므로 변환 필요
        if let currentUserIdStr = user?.id, let currentUserId = Int(currentUserIdStr), currentUserId == userId {
            DispatchQueue.main.async {
                self.isFriendRequestSent = true
            }
        }
    }
    
    /// 친구 삭제 (DELETE /api/friend/{friendId})
    /// 우선 친구 목록을 조회하여 해당 닉네임의 friendId를 찾은 뒤 삭제 요청
    func deleteFriend(completion: @escaping (Bool, String?) -> Void) {
        guard let user = user else {
            completion(false, "사용자 정보를 찾을 수 없습니다.")
            return
        }
        
        let targetNickname = user.name
        print("🗑 [Profile] 친구 삭제 시도: 닉네임=\(targetNickname)의 ID 찾기...")
        
        // 1. 친구 목록 조회
        friendsNetworkManager.request(
            target: .getFriends,
            decodingType: FriendsPageDTO.self
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let page):
                // 2. 닉네임으로 매칭되는 친구 찾기
                if let friend = page.content.first(where: { $0.friendNickname == targetNickname }) {
                    let friendId = friend.friendId
                    print("✅ [Profile] 삭제 대상 ID 발견: \(friendId) (API ID)")
                    
                    // 3. 찾은 ID로 삭제 요청
                    self.performDeleteFriend(friendId: friendId, completion: completion)
                } else {
                    print("❌ [Profile] 친구 목록에서 해당 닉네임을 찾을 수 없음")
                    // 목록에 없으면 이미 삭제된 것으로 간주할 수도 있음
                    self.isFriend = false
                    completion(true, nil)
                }
                
            case .failure(let error):
                print("❌ [Profile] 친구 목록 조회 실패: \(error)")
                completion(false, "친구 목록을 불러오는데 실패했습니다.")
            }
        }
    }
    
    private func performDeleteFriend(friendId: Int, completion: @escaping (Bool, String?) -> Void) {
        print("🗑 [Profile] 실제 친구 삭제 요청 전송: friendId=\(friendId)")
        
        friendsNetworkManager.requestStatusCode(
            target: .deleteFriend(friendId: friendId)
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                     print("✅ [Profile] 친구 삭제 성공")
                     self.isFriend = false
                     self.isFriendRequestSent = false
                     completion(true, nil)
                case .failure(let error):
                     print("❌ [Profile] 친구 삭제 실패: \(error)")
                     completion(false, error.localizedDescription)
                }
            }
        }
    }
}

private struct UserMeResponseDTO: Decodable {
    let userId: Int
    let nickname: String
    let bio: String?
    let statusMessage: String?
    let profileImageUrl: String?
    let isFriend: Bool?
    let thumbnailResponse: UserMeThumbnailPageDTO?

    enum CodingKeys: String, CodingKey {
        case userId
        case nickname
        case bio
        case statusMessage
        case profileImageUrl
        case profileImage
        case profileImageURL = "profile_image_url"
        case isFriend
        case thumbnailResponse
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        userId = try c.decode(Int.self, forKey: .userId)
        nickname = try c.decode(String.self, forKey: .nickname)
        bio = try c.decodeIfPresent(String.self, forKey: .bio)
        statusMessage = try c.decodeIfPresent(String.self, forKey: .statusMessage)
        isFriend = try c.decodeIfPresent(Bool.self, forKey: .isFriend)

        if let url = try c.decodeIfPresent(String.self, forKey: .profileImageUrl) {
            profileImageUrl = url
        } else if let url = try c.decodeIfPresent(String.self, forKey: .profileImage) {
            profileImageUrl = url
        } else if let url = try c.decodeIfPresent(String.self, forKey: .profileImageURL) {
            profileImageUrl = url
        } else {
            profileImageUrl = nil
        }

        thumbnailResponse = try c.decodeIfPresent(UserMeThumbnailPageDTO.self, forKey: .thumbnailResponse)
    }
}

private struct UserMeThumbnailPageDTO: Decodable {
    let content: [UserMeThumbnailDTO]
    let pageNumber: Int?
    let pageSize: Int?
    let totalElements: Int?
    let totalPages: Int?
    let first: Bool?
    let last: Bool?
}

private struct UserMeThumbnailDTO: Decodable {
    let challengeId: Int
    let repImageUrl: String
}
