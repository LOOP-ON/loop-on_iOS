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

    var hasLoggedInBefore: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }

    func markLoggedIn() {
        hasLoggedInBefore = true
    }

    /// 서버 로그아웃 API를 호출한 뒤 로컬 세션을 정리합니다.
    /// - Note: refresh 토큰이 별도 저장되어 있지 않아 현재는 accessToken을 `refresh_token`으로 전달합니다.
    func logout(completion: ((Bool) -> Void)? = nil) {
        let accessToken = KeychainService.shared.loadToken()

        // 내부 정리 로직
        let clearSession: (Bool) -> Void = { [weak self] success in
            KeychainService.shared.deleteToken()
            self?.hasLoggedInBefore = false
            completion?(success)
        }

        guard let token = accessToken, !token.isEmpty else {
            // 토큰이 없으면 서버 호출 없이 바로 로그아웃 처리
            clearSession(true)
            return
        }

        let networkManager = DefaultNetworkManager<AuthAPI>()
        networkManager.request(
            target: .logout(refreshToken: token),
            decodingType: String.self
        ) { result in
            // 성공/실패 여부와 관계 없이 로컬 세션은 정리
            switch result {
            case .success:
                clearSession(true)
            case .failure:
                clearSession(false)
            }
        }
    }
}
