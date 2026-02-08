//
//  Config.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import Foundation

enum Config {
    /// xcconfig가 적용되지 않아 BASE_URL이 "https://api" 등으로 잘릴 때 사용하는 폴백 (호스트에 '.' 없으면 사용)
    private static let baseURLFallback = "https://api.loopon.cloud"

    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist 없음")
        }
        return dict
    }()

    static let baseURL: String = {
        guard let raw = Config.infoDictionary["BASE_URL"] as? String else {
            return baseURLFallback
        }
        let baseURL = raw.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        // 올바른 도메인이 아니면 폴백 사용 (xcconfig 잘림 시 https://api 등으로 들어옴)
        guard baseURL.contains("loopon.cloud") else {
            #if DEBUG
            print("📍 BASE_URL이 잘림(\(baseURL)) → 폴백 사용: \(baseURLFallback)")
            #endif
            return baseURLFallback
        }
        return baseURL
    }()
}
