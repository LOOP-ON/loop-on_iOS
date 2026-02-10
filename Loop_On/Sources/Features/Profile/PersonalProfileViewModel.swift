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
        // TODO: Fetch user profile from API
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.user = UserModel(
                id: "1",
                name: "서리",
                profileImageURL: nil,
                bio: "LOOP:ON 디자이너 서리/최서정\n룸온팀 파이팅!!"
            )
            #if DEBUG
            // UI 확인용 더미 피드 (디버그 빌드에서만 사용)
            let dummyCount = 12
            self?.challengeImages = Array(repeating: "", count: dummyCount)
            self?.myChallengeItems = (0..<dummyCount).map { MyChallengeItemDTO(challengeId: $0 + 1, imageUrl: "") }
            #else
            self?.loadMyChallenges(reset: true)
            #endif
            self?.isLoading = false
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
