//
//  HistoryViewModel.swift
//  Loop_On
//
//  Created by Auto on 1/1PrimaryColor-Varient 655/26.
//

import Foundation
import SwiftUI

// MARK: - History Journey Report Model
struct HistoryJourneyReport {
    let date: Date
    let goal: String
    let routines: [HistoryRoutineReport]
}

struct HistoryRoutineReport: Identifiable {
    let id: Int
    let name: String
    let status: HistoryRoutineStatus
}

enum HistoryRoutineStatus {
    case completed
    case postponed
    
    var displayText: String {
        switch self {
        case .completed:
            return "완료"
        case .postponed:
            return "미룸"
        }
    }
}

@MainActor
class HistoryViewModel: ObservableObject {
    // 날짜별 루틴 달성 개수 (예시 데이터)
    // 실제로는 API에서 가져와야 함
    @Published var routineCompletionCount: [Date: Int] = [:]
    
    // 날짜별 리포트 데이터 (예시 데이터)
    @Published var journeyReports: [Date: HistoryJourneyReport] = [:]
    
    // #region agent log
    /// 디버그 모드용 간단한 로깅 헬퍼 (HTTP POST → host 로그 서버)
    private func agentLog(runId: String, hypothesisId: String, location: String, message: String, data: [String: Any]) {
        guard let url = URL(string: "http://127.0.0.1:7242/ingest/f0d53358-e857-43b6-9baf-1b348ed6f40f") else { return }
        
        var payload: [String: Any] = [
            "sessionId": "debug-session",
            "runId": runId,
            "hypothesisId": hypothesisId,
            "location": location,
            "message": message,
            "data": data,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        let bodyData = (try? JSONSerialization.data(withJSONObject: payload)) ?? Data()
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            // fire-and-forget
        }.resume()
    }
    // #endregion
    
    init() {
        // #region agent log
        agentLog(
            runId: "pre-fix-2",
            hypothesisId: "H3",
            location: "HistoryViewModel.swift:init:entry",
            message: "HistoryViewModel initializing",
            data: [:]
        )
        // #endregion
        
        // 예시 데이터 - 실제로는 API에서 가져와야 함
        setupExampleData()
        setupExampleReports()
        
        // #region agent log
        agentLog(
            runId: "pre-fix-2",
            hypothesisId: "H3",
            location: "HistoryViewModel.swift:init:exit",
            message: "HistoryViewModel init completed",
            data: [
                "completionCountKeys": routineCompletionCount.keys.count,
                "reportsCount": journeyReports.keys.count
            ]
        )
        // #endregion
    }
    
    /// 특정 날짜의 루틴 달성 개수 반환
    func getCompletionCount(for date: Date) -> Int {
        // #region agent log
        let logData: [String: Any] = [
            "sessionId": "debug-session",
            "runId": "run1",
            "hypothesisId": "B",
            "location": "HistoryViewModel.swift:getCompletionCount:entry",
            "message": "Getting completion count",
            "data": ["date": date.timeIntervalSince1970]
        ]
        if let jsonData = try? JSONSerialization.data(withJSONObject: logData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            try? jsonString.write(toFile: "/Users/surfing_seal/Desktop/loop-on_iOS/.cursor/debug.log", atomically: false, encoding: .utf8)
        }
        // #endregion
        
        let calendar = Calendar.current
        let dateKey = calendar.startOfDay(for: date)
        let count = routineCompletionCount[dateKey] ?? 0
        
        // #region agent log
        let logData2: [String: Any] = [
            "sessionId": "debug-session",
            "runId": "run1",
            "hypothesisId": "B",
            "location": "HistoryViewModel.swift:getCompletionCount:exit",
            "message": "Completion count retrieved",
            "data": ["count": count, "dateKey": dateKey.timeIntervalSince1970]
        ]
        if let jsonData = try? JSONSerialization.data(withJSONObject: logData2),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            try? jsonString.write(toFile: "/Users/surfing_seal/Desktop/loop-on_iOS/.cursor/debug.log", atomically: false, encoding: .utf8)
        }
        // #endregion
        
        return count
    }
    
    /// 특정 날짜의 리포트 반환
    func getReport(for date: Date) -> HistoryJourneyReport? {
        // #region agent log
        let logData: [String: Any] = [
            "sessionId": "debug-session",
            "runId": "run1",
            "hypothesisId": "E",
            "location": "HistoryViewModel.swift:getReport:entry",
            "message": "Getting report",
            "data": ["date": date.timeIntervalSince1970]
        ]
        if let jsonData = try? JSONSerialization.data(withJSONObject: logData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            try? jsonString.write(toFile: "/Users/surfing_seal/Desktop/loop-on_iOS/.cursor/debug.log", atomically: false, encoding: .utf8)
        }
        // #endregion
        
        let calendar = Calendar.current
        let dateKey = calendar.startOfDay(for: date)
        let report = journeyReports[dateKey]
        
        // #region agent log
        let logData2: [String: Any] = [
            "sessionId": "debug-session",
            "runId": "run1",
            "hypothesisId": "E",
            "location": "HistoryViewModel.swift:getReport:exit",
            "message": "Report retrieved",
            "data": ["hasReport": report != nil, "dateKey": dateKey.timeIntervalSince1970]
        ]
        if let jsonData = try? JSONSerialization.data(withJSONObject: logData2),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            try? jsonString.write(toFile: "/Users/surfing_seal/Desktop/loop-on_iOS/.cursor/debug.log", atomically: false, encoding: .utf8)
        }
        // #endregion
        
        return report
    }
    
    /// 특정 날짜에 루틴 기록이 있는지 확인
    func hasRoutineRecords(for date: Date) -> Bool {
        return getCompletionCount(for: date) > 0
    }
    
    /// 예시 데이터 설정 (개발용)
    private func setupExampleData() {
        // #region agent log
        let logData: [String: Any] = [
            "sessionId": "debug-session",
            "runId": "run1",
            "hypothesisId": "A",
            "location": "HistoryViewModel.swift:setupExampleData:entry",
            "message": "Setting up example data",
            "data": [:]
        ]
        if let jsonData = try? JSONSerialization.data(withJSONObject: logData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            try? jsonString.write(toFile: "/Users/surfing_seal/Desktop/loop-on_iOS/.cursor/debug.log", atomically: false, encoding: .utf8)
        }
        // #endregion
        
        let calendar = Calendar.current
        let today = Date()
        
        // 예시: 최근 며칠간의 달성 데이터
        for i in 0..<31 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dateKey = calendar.startOfDay(for: date)
                // 랜덤하게 0~3개의 달성 개수 설정
                routineCompletionCount[dateKey] = Int.random(in: 0...3)
            }
        }
        
        // #region agent log
        let logData2: [String: Any] = [
            "sessionId": "debug-session",
            "runId": "run1",
            "hypothesisId": "A",
            "location": "HistoryViewModel.swift:setupExampleData:exit",
            "message": "Example data setup completed",
            "data": ["count": routineCompletionCount.count]
        ]
        if let jsonData = try? JSONSerialization.data(withJSONObject: logData2),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            try? jsonString.write(toFile: "/Users/surfing_seal/Desktop/loop-on_iOS/.cursor/debug.log", atomically: false, encoding: .utf8)
        }
        // #endregion
    }
    
    /// 예시 리포트 데이터 설정 (개발용)
    private func setupExampleReports() {
        let calendar = Calendar.current
        let today = Date()
        
        // 예시: 최근 며칠간의 리포트 데이터
        // setupExampleData()에서 설정한 completionCount를 기반으로 리포트 생성
        for i in 0..<31 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dateKey = calendar.startOfDay(for: date)
                
                // routineCompletionCount에 값이 있는 경우에만 리포트 생성
                if let completionCount = routineCompletionCount[dateKey] {
                    // 날짜 밑 점 색깔(달성 개수)에 따라 루틴 상태를 분배
                    // 3개 달성 → 3개 모두 완료
                    // 2개 달성 → 2개 완료, 1개 미룸
                    // 1개 달성 → 1개 완료, 2개 미룸
                    // 0개 달성 → 3개 모두 미룸
                    let clampedCount = max(0, min(completionCount, 3))
                    let routines: [HistoryRoutineReport] = (1...3).map { idx in
                        let status: HistoryRoutineStatus = idx <= clampedCount ? .completed : .postponed
                        return HistoryRoutineReport(id: idx, name: "루틴 \(idx)", status: status)
                    }
                    
                    journeyReports[dateKey] = HistoryJourneyReport(
                        date: date,
                        goal: "건강한 생활 만들기",
                        routines: routines
                    )
                }
            }
        }
    }
}
