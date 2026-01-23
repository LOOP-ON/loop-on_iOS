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
    let totalRoutines: Int
    let completedRoutines: Int
    let routines: [RoutineDTO]
}

struct RoutineDTO: Codable {
    let id: Int
    let title: String
    let alarmTime: String
    let isCompleted: Bool
}

// MARK: - Domain Model
// 앱 내 로직에서 사용할 모델 (Identifiable 준수)
struct RoutineModel: Identifiable {
    let id: Int
    let title: String
    let time: String
    var isCompleted: Bool
}

struct JourneyInfo {
    let loopId: Int
    let currentDay: Int
    let totalCount: Int
    let completedCount: Int
}
