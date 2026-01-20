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
    let birthDate: String
}
