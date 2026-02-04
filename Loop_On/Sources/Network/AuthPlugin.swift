//
//  AuthPlugin.swift
//  Loop_On
//
//  Created by Auto on 1/30/26.
//

//  Moya 요청 시 키체인에 저장된 accessToken을 Authorization 헤더에 붙입니다.
//  서버 연동 후 인증이 필요한 API(프로필, 게시글 등)는 이 플러그인을 쓰는 Provider로 호출하면 됩니다.
import Foundation
import Moya

/// 키체인에서 accessToken을 읽어 `Authorization: Bearer <token>` 헤더를 추가하는 Moya 플러그인.
/// 토큰이 없으면 헤더를 추가하지 않습니다 (로그인/회원가입 등에는 영향 없음).
final class AuthPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let token = KeychainService.shared.loadToken(), !token.isEmpty else {
            return request
        }
        var request = request
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
