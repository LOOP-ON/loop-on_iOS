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
//        KeychainService.shared.loadToken() != nil
        
        // 잠시 테스트용으로 로직 바꿈 나중에 이거 지우고 주석해둔거 주석 해제
        isLoggedIn || KeychainService.shared.loadToken() != nil
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

    func logout() {
        KeychainService.shared.deleteToken()
        self.isLoggedIn = false
        self.isOnboardingCompleted = false
        self.hasValidatedSessionAtLaunch = false
    }
    
    // 서버에서 프로필 정보를 가져오는 함수 추가
    func fetchUserProfile() {
        if let token = KeychainService.shared.loadToken() {
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
