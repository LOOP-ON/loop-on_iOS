//
//  AppRoute.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import Foundation

/// 네비게이션 경로 복원 시 NavigationPath 디코딩에 필요
enum AppRoute: Hashable, Codable {
    case home
    case detail(title: String)
    case profile(userID: Int)
    case routineCoach
    case settings
    case account
    case notifications
    case system
    case goalSelect
    case onBoarding
    case goalInput(category: String)
    case insightSelect(goalText: String, category: String, insights: [String])
}
