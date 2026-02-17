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
    private var hasValidatedSessionAtLaunch = false
    
    var isLoggedIn: Bool = false
    var currentUserNickname: String = "" // 닉네임을 담을 변수

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
    }
    
    // 서버에서 프로필 정보를 가져오는 함수
    func fetchUserProfile() {
        if let token = KeychainService.shared.loadToken(), !token.isEmpty {
            print("DEBUG: 토큰 확인됨 - \(token.prefix(10))...")
        } else {
            print("DEBUG: 토큰이 없습니다! 로그인이 필요합니다.")
            return
        }
        
        networkManager.request(target: .getMe, decodingType: UserMeData.self) { [weak self] result in
            switch result {
            case .success(let userData):
                DispatchQueue.main.async {
                    self?.currentUserNickname = userData.nickname
                    print("DEBUG: 닉네임 불러오기 성공 - \(userData.nickname)")
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
