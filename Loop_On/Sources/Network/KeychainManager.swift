//
//  KeychainManager.swift
//  Loop_On
//
//  Created by 이경민 on 1/29/26.
//
//  서버에서 받은 accessToken을 키체인에 보관하여 로그인 정보를 관리합니다.
//

import Foundation
import Security

/// accessToken 등 민감한 로그인 정보를 키체인에 저장/조회하는 서비스.
/// Moya API 요청 시 AuthPlugin이 여기서 토큰을 읽어 Authorization 헤더에 붙입니다.
final class KeychainService {
    static let shared = KeychainService()
    private init() {}

    private let account = "accessToken"
    private let service = "com.loopon.auth"

    /// 현재 키체인에 accessToken이 있는지 여부 (로그인 유효 세션 판단용).
    var hasAccessToken: Bool { loadToken() != nil }

    @discardableResult
    func saveToken(_ token: String) -> OSStatus {
        guard let data = token.data(using: .utf8) else { return errSecParam }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        // 기존 항목이 있으면 삭제 후 추가 (덮어쓰기)
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil)
    }

    /// 저장된 accessToken 반환. 없으면 nil.
    func loadToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// 로그아웃 시 호출. 키체인에서 accessToken 제거.
    @discardableResult
    func deleteToken() -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]
        return SecItemDelete(query as CFDictionary)
    }
}
