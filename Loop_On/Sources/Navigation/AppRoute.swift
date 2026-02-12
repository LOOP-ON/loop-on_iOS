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
    /// 루틴 코치 화면 진입 시 생성된 루틴 목록과 요청 컨텍스트를 함께 전달
    case routineCoach(
        routines: [RoutineCoach],
        goal: String,
        category: String,
        selectedInsights: [String],
        showContinuationPopup: Bool
    )
    case settings
    case account
    case notifications
    case system
    case goalSelect
    case onBoarding
    case goalInput(category: String)
    /// 목표 입력 단계에서 받은 journeyId를 인사이트 선택 및 루틴 코치까지 전달
    case insightSelect(goalText: String, category: String, insights: [String])
}
