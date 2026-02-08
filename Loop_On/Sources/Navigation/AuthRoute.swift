//
//  Route.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import SwiftUI

/// 네비게이션 경로 복원 시 NavigationPath 디코딩에 필요
enum AuthRoute: Hashable, Codable {
    case login
    case signUp
    case setProfile
    case findPassword
}
