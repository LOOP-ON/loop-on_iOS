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
    /// 이름 - 현재 화면에서는 입력하지 않고, 나중에 프로필 단계에서 별도 API로 관리
    let name: String?
    /// 닉네임 - 현재 화면에서는 입력하지 않고, 나중에 프로필 단계에서 별도 API로 관리
    let nickname: String?
    /// 생년월일 - 현재 화면에서는 입력하지 않고, 나중에 프로필 단계에서 별도 API로 관리
    let birthDate: String?
}
