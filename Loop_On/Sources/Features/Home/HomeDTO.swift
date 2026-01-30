//
//  HomeDTO.swift
//  Loop_On
//
//  Created by 이경민 on 1/23/26.
//

import Foundation

// MARK: - Server DTO (Data Transfer Object)
// 서버로부터 받을 원본 데이터 구조
struct HomeDataResponseDTO: Codable {
    let loopId: Int
    let title: String
    let currentDay: Int
    let totalJourney: Int
    let completedJourney: Int
    let todayRoutine: Int    // 오늘 목표 루틴 개수 (기초값 3)
    var todayRoutineCount: Int // 오늘 실제 완료한 루틴 개수
    var yesterdayRoutineCount: Int // 어제 완료한 루틴 개수
    let routines: [RoutineDTO]
}

struct RoutineDTO: Codable {
    let id: Int
    let title: String
    var alarmTime: String
    let isCompleted: Bool
    var isDelayed: Bool
    var delayReason: String
}

// MARK: - Domain Model
// 앱 내 로직에서 사용할 모델 (Identifiable 준수)
struct RoutineModel: Identifiable {
    let id: Int
    let title: String
    var time: String
    var isCompleted: Bool
    var isDelayed: Bool
    var delayReason: String
}

struct JourneyInfo {
    let loopId: Int
    let currentDay: Int
    let totalJourney: Int    // 전체 여정 기간 (일수)
    var completedJourney: Int // 완료된 일수
    let todayRoutine: Int    // 오늘 목표 루틴 개수 (기초값 3)
    var todayRoutineCount: Int // 오늘 실제 완료한 루틴 개수
    var yesterdayRoutineCount: Int // 어제 완료한 루틴 개수
}

// MARK: - Reflection Reques벼t DTO
struct ReflectionRequestDTO: Codable {
    let loopId: Int
    let day: Int
    let content: String
    let imageCount: Int
}
