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
    let name: String
    let nickname: String
    let birthDate: String // 서버 규격에 따라 Date 타입이 될 수도 있음
    // 프로필 이미지는 보통 MultipartFormData로 따로 보내므로 모델에서는 제외하는 경우가 많습니다.
}
