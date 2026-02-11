//
//  HomeDTO.swift
//  Loop_On
//
//  Created by 이경민 on 1/23/26.
//

import Foundation

// MARK: - Server DTO (Data Transfer Object)
struct HomeDataResponseDTO: Codable {
    let result: String
    let code: String
    let message: String
    let data: HomeDataDetail
    let timestamp: String
}

struct HomeDataDetail: Codable {
    let journey: JourneyDTO
    let todayProgress: ProgressDTO
    let routines: [RoutineDTO]
    let isNotReady: Bool
    let targetDate: String
}

struct JourneyDTO: Codable {
    let journeyId: Int
    let journeyOrder: Int // n번째 여정
    let journeyDate: Int  // n일차 여정
    let journeyCategory: String
    let goal: String
}

struct ProgressDTO: Codable {
    let completedCount: Int
    let totalCount: Int
}

struct RoutineDTO: Codable {
    let routineId: Int
    let routineProgressId: Int
    let content: String           // 기존 title 역할
    let notificationTime: String  // 기존 alarmTime 역할
    let status: String            // "IN_PROGRESS", "COMPLETED" 등
    
    // 상태 문자열을 바탕으로 한 편의 속성
    var isCompleted: Bool { status == "COMPLETED" }
    var isDelayed: Bool { status == "DELAYED" } // 서버 상태값에 따라 조정 필요
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
