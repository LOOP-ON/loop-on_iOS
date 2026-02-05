//
//  SignUpRequest.swift
//  Loop_On
//
//  Created by 이경민 on 1/19/26.
//

import Foundation

struct SignUpRequest: Codable {
    let email: String
    let password: String
    let confirmPassword: String
    /// 닉네임 - 백엔드 회원가입 명세(`/api/users`)에서 필수일 수 있어 프로필 단계에서 최종 입력 후 전송
    let nickname: String
    /// 프로필 이미지 URL - 이미지 업로드 API(`/api/users/upload-profile-image`) 성공 후 받은 URL을 전송
    /// - NOTE: 이미지 선택/업로드 UI가 아직 없어서 nil 가능하도록 설계
    let profileImageUrl: String?
    /// 약관 동의 ID 목록 (예: [1,2,3,6])
    let agreedTermIds: [Int]
}
