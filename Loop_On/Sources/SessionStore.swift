//
//  SessionStore.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import Foundation
import Observation

@Observable
final class SessionStore {
    private let key = "hasLoggedInBefore"
    private let keyOnboarding = "isOnboardingCompleted"
    private let networkManager = DefaultNetworkManager<ProfileAPI>() // 프로필 API 매니저
    private let homeNetworkManager = DefaultNetworkManager<HomeAPI>() // 홈 API 매니저
    private var hasValidatedSessionAtLaunch = false
    
    var isLoggedIn: Bool = false
    var currentUserNickname: String = ""
    var currentUserEmail: String = ""

    private let keyLoginProvider = "loginProvider" // 로그인 제공자 저장 키

    var socialProvider: String? {
        get { UserDefaults.standard.string(forKey: keyLoginProvider) }
        set { UserDefaults.standard.set(newValue, forKey: keyLoginProvider) }
    }
    var currentJourneyId: Int = 0 { // 현재 진행 중인 여정 ID (HomeViewModel 등에서 업데이트)
        didSet {
            print("DEBUG: [SessionStore] currentJourneyId updated: \(oldValue) -> \(currentJourneyId)")
        }
    }

    var isOnboardingCompleted: Bool {
        get { UserDefaults.standard.bool(forKey: keyOnboarding) }
        set { UserDefaults.standard.set(newValue, forKey: keyOnboarding) }
    }
    
    var hasValidToken: Bool {
        let token = KeychainService.shared.loadToken()?.trimmingCharacters(in: .whitespacesAndNewlines)
        return isLoggedIn || !(token?.isEmpty ?? true)
    }
    
    var hasLoggedInBefore: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }

    func markLoggedIn() {
        self.isLoggedIn = true
        fetchUserProfile() // 로그인 성공 시 프로필 정보 가져오기
    }

    func validateSessionAtLaunchIfNeeded() {
        guard hasValidToken else { return }
        guard !hasValidatedSessionAtLaunch else { return }
        hasValidatedSessionAtLaunch = true
        fetchUserProfile()
    }
    
    func completeOnboarding() {
        self.isOnboardingCompleted = true
    }

    /// 다음에 RootTabView가 나타날 때 히스토리 탭을 선택할지 여부 (로그인 후 온보딩 스킵 시 사용)
    var selectHistoryTabOnNextAppear: Bool = false

    /// 서버 로그아웃 API를 호출한 뒤 로컬 세션을 정리합니다.
    /// - Note: refresh 토큰이 별도 저장되어 있지 않아 현재는 accessToken을 `refresh_token`으로 전달합니다.
    func logout(completion: ((Bool) -> Void)? = nil) {
        let accessToken = KeychainService.shared.loadToken()
        clearSessionState()
        completion?(true)

        guard let token = accessToken, !token.isEmpty else {
            return
        }

        let networkManager = DefaultNetworkManager<AuthAPI>()
        networkManager.request(
            target: .logout(refreshToken: token),
            decodingType: String.self
        ) { result in
            // 서버 로그아웃은 best-effort
            if case .failure(let error) = result {
                print("DEBUG: 서버 로그아웃 실패 - \(error.localizedDescription)")
            }
        }
    }

    private func clearSessionState() {
        KeychainService.shared.deleteToken()
        hasLoggedInBefore = false
        isLoggedIn = false
        isOnboardingCompleted = false
        hasValidatedSessionAtLaunch = false
        currentJourneyId = 0
        currentUserNickname = ""
        currentUserEmail = ""
        socialProvider = nil
    }
    
    // 현재 여정 ID 동기화 함수
    func syncCurrentJourneyId(completion: ((Int?) -> Void)? = nil) {
        guard let token = KeychainService.shared.loadToken(), !token.isEmpty else {
            completion?(nil)
            return
        }
        
        homeNetworkManager.request(
            target: .fetchCurrentJourney, 
            decodingType: HomeDataDetail.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    let journeyId = data.journey.journeyId
                    self?.currentJourneyId = journeyId
                    print("DEBUG: [SessionStore] 여정 ID 동기화 성공 - \(journeyId)")
                    completion?(journeyId)
                case .failure(let error):
                    print("DEBUG: [SessionStore] 여정 ID 동기화 실패 - \(error.localizedDescription)")
                    completion?(nil)
                }
            }
        }
    }
    
    // 서버에서 프로필 정보를 가져오는 함수
    func fetchUserProfile() {
        if let token = KeychainService.shared.loadToken(), !token.isEmpty {
            print("DEBUG: 토큰 확인됨 - \(token.prefix(10))...")
        } else {
            print("DEBUG: 토큰이 없습니다! 로그인이 필요합니다.")
            return
        }
        
        // TODO: sort 파라미터가 필요한지 확인 필요. 단순히 내 정보 조회라면 getMe(plain)이 나을 수 있음
        // 아래 코드는 기존 유지: page/size/sort 사용
        networkManager.request(target: .getMe(page: 0, size: 10, sort: ["createdAt,desc"]), decodingType: UserMeData.self) { [weak self] result in
            switch result {
            case .success(let userData):
                DispatchQueue.main.async {
                    self?.currentUserNickname = userData.nickname
                    self?.currentUserEmail = userData.email
                    print("DEBUG: 닉네임/이메일 불러오기 성공 - \(userData.nickname), \(userData.email)")
                }
            case .failure(let error):
                print("DEBUG: 프로필 조회 실패 - \(error.localizedDescription)")
                if case .unauthorized = error {
                    DispatchQueue.main.async {
                        self?.logout()
                    }
                }
            }
        }
    }
}

struct UserMeData: Decodable {
    let userId: Int
    let nickname: String
    let email: String
    let profileImageUrl: String?
    // 필요하다면 bio, statusMessage 등 추가
}
