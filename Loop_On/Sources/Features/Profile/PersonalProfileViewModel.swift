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
    @Published var errorMessage: String?

    /// 개인이 올린 챌린지 이미지 URL 목록 (GET /api/challenges/users/me 연동)
    @Published var challengeImages: [String] = []
    /// 내 챌린지 전체 (challengeId + imageUrl). 그리드에서 탭 시 피드 상세용. API 순서 = 최신순(인덱스 0이 최신)
    @Published var myChallengeItems: [MyChallengeItemDTO] = []

    private let challengeNetworkManager = DefaultNetworkManager<ChallengeAPI>()
    private let profileNetworkManager = DefaultNetworkManager<ProfileAPI>()
    
    // 내 챌린지 피드 페이지네이션 상태
    private var myChallengesPage: Int = 0
    private let myChallengesPageSize: Int = 20
    private var isLoadingMyChallenges: Bool = false
    private var hasMoreMyChallenges: Bool = true

    init() {
        loadProfile()
    }

    func loadProfile() {
        isLoading = true
        errorMessage = nil

        profileNetworkManager.request(
            target: .getMe(page: 0, size: 20, sort: ["createdAt,desc"]),
            decodingType: UserMeResponseDTO.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let profile):
                    let nickname = profile.nickname.trimmingCharacters(in: .whitespacesAndNewlines)
                    let bio = profile.bio?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    let statusMessage = profile.statusMessage?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    
                    print("✅ [Profile] /api/users/me 연동 성공: 닉네임(\(nickname)), 한줄소개(\(bio)), 상태메시지(\(statusMessage))")
                    
                    // 한줄소개(bio)가 먼저 오고, 그 다음 줄에 상태메시지가 오도록 구성 (요청사항 반영)
                    let composedBio = [bio, statusMessage]
                        .filter { !$0.isEmpty }
                        .joined(separator: "\n")
                        
                    self.user = UserModel(
                        id: String(profile.userId),
                        name: nickname.isEmpty ? "사용자" : nickname,
                        profileImageURL: profile.profileImageUrl,
                        bio: composedBio.isEmpty ? "소개가 아직 없어요." : composedBio
                    )

                    let thumbItems = profile.thumbnailResponse?.content ?? []
                    if !thumbItems.isEmpty {
                        self.myChallengeItems = thumbItems.map {
                            MyChallengeItemDTO(challengeId: $0.challengeId, imageUrl: $0.repImageUrl)
                        }
                        self.challengeImages = self.myChallengeItems.map(\.imageUrl)
                    } else {
                        self.loadMyChallenges(reset: true)
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
                    self.loadMyChallenges(reset: true)
                    print("❌ [Profile] /api/users/me failed: \(error)")
                }
            }
        }
    }

    /// GET /api/challenges/users/me — 내 챌린지 목록을 가져와 이미지 URL로 표시
    func loadMyChallenges(reset: Bool = false) {
        // 이미 로딩 중이면 중복 요청 방지
        guard !isLoadingMyChallenges else { return }
        
        if reset {
            myChallengesPage = 0
            hasMoreMyChallenges = true
        } else {
            // 더 가져올 페이지가 없으면 종료
            guard hasMoreMyChallenges else { return }
        }
        
        isLoadingMyChallenges = true
        
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
    
    /// 스크롤이 끝에 가까워졌을 때 다음 페이지를 로드
    func loadMoreChallengesIfNeeded(currentIndex: Int) {
        let thresholdIndex = max(challengeImages.count - 4, 0)
        if currentIndex >= thresholdIndex {
            loadMyChallenges(reset: false)
        }
    }

    func refreshProfile() {
        loadProfile()
    }
}

private struct UserMeResponseDTO: Decodable {
    let userId: Int
    let nickname: String
    let bio: String?
    let statusMessage: String?
    let profileImageUrl: String?
    let thumbnailResponse: UserMeThumbnailPageDTO?

    enum CodingKeys: String, CodingKey {
        case userId
        case nickname
        case bio
        case statusMessage
        case profileImageUrl
        case profileImage
        case profileImageURL = "profile_image_url"
        case thumbnailResponse
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        userId = try c.decode(Int.self, forKey: .userId)
        nickname = try c.decode(String.self, forKey: .nickname)
        bio = try c.decodeIfPresent(String.self, forKey: .bio)
        statusMessage = try c.decodeIfPresent(String.self, forKey: .statusMessage)

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
}

private struct UserMeThumbnailDTO: Decodable {
    let challengeId: Int
    let repImageUrl: String
}
