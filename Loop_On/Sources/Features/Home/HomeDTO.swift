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
    let isNotReady: Bool?
    let targetDate: String?
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
    let routineProgressId: Int?
    let content: String           // 기존 title 역할
    let notificationTime: String  // 기존 alarmTime 역할
    let status: String            // "IN_PROGRESS", "COMPLETED" 등
    
    // 상태 문자열을 바탕으로 한 편의 속성
    var isCompleted: Bool { status == "COMPLETED" }
    var isDelayed: Bool { status == "DELAYED" || status == "POSTPONED" }
}

struct RoutinePostponeRequest: Codable {
    let progressIds: [Int]
    let reason: String
}

struct RoutinePostponeReasonData: Codable {
    let progressId: Int
    let content: String
    let reason: String
}

struct RoutinePostponeReasonUpdateRequest: Codable {
    let reason: String
}

struct RoutinePostponeReasonUpdateData: Codable {
    let progressId: Int
    let reason: String
}

struct RoutineCertifyData: Codable {
    let progressId: Int
    let status: String
    let imageUrl: String?
}

struct JourneyContinueData: Codable {
    let goal: String
    let originalJourneyId: Int
    let continuation: Bool
}

struct JourneyRecordRoutineDTO: Codable {
    let routineId: Int
    let routineName: String
}

struct JourneyRecordData: Codable {
    let journeyId: Int
    let goal: String
    let routines: [JourneyRecordRoutineDTO]
    let day1Rate: Double
    let day2Rate: Double
    let day3Rate: Double
    let totalRate: Double

    enum CodingKeys: String, CodingKey {
        case journeyId
        case goal
        case routines
        case day1Rate
        case day2Rate
        case day3Rate
        case totalRate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        journeyId = try container.decode(Int.self, forKey: .journeyId)
        goal = try container.decode(String.self, forKey: .goal)
        routines = try container.decode([JourneyRecordRoutineDTO].self, forKey: .routines)
        day1Rate = try container.decodeFlexibleDouble(forKey: .day1Rate)
        day2Rate = try container.decodeFlexibleDouble(forKey: .day2Rate)
        day3Rate = try container.decodeFlexibleDouble(forKey: .day3Rate)
        totalRate = try container.decodeFlexibleDouble(forKey: .totalRate)
    }
}

private extension KeyedDecodingContainer where K == JourneyRecordData.CodingKeys {
    func decodeFlexibleDouble(forKey key: K) throws -> Double {
        if let value = try? decode(Double.self, forKey: key) {
            return value
        }
        if let intValue = try? decode(Int.self, forKey: key) {
            return Double(intValue)
        }
        if let stringValue = try? decode(String.self, forKey: key),
           let parsed = Double(stringValue) {
            return parsed
        }
        return 0
    }
}

struct RoutineRecordRequest: Codable {
    let content: String
}

struct RoutineRecordData: Codable {
    let routineReportId: Int
    let content: String
}

// MARK: - Domain Model
// 앱 내 로직에서 사용할 모델 (Identifiable 준수)
struct RoutineModel: Identifiable {
    let id: Int
    let routineProgressId: Int
    let title: String
    var time: String
    var isCompleted: Bool
    var isDelayed: Bool
    var delayReason: String
}

struct JourneyInfo {
    let journeyId: Int
    let loopId: Int
    let currentDay: Int
    let totalJourney: Int    // 전체 여정 기간 (일수)
    var completedJourney: Int // 완료된 일수
    let todayRoutine: Int    // 오늘 목표 루틴 개수 (기초값 3)
    var todayRoutineCount: Int // 오늘 실제 완료한 루틴 개수
    var yesterdayRoutineCount: Int // 어제 완료한 루틴 개수
}

// MARK: - Reflection Request DTO
struct ReflectionRequestDTO: Codable {
    let loopId: Int
    let day: Int
    let content: String
    let imageCount: Int
}
