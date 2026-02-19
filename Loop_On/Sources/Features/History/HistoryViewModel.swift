//
//  HistoryViewModel.swift
//  Loop_On
//
//  Created by Auto on 1/1PrimaryColor-Varient 655/26.
//

import Foundation
import SwiftUI
import Moya

// MARK: - History API (월별 루틴 수행 개수 / 일일 리포트)
enum HistoryAPI {
    case fetchMonthly(year: Int, month: Int)
    case fetchDailyReport(date: String) // yyyy-MM-dd
}

extension HistoryAPI: TargetType {
    var baseURL: URL { URL(string: API.baseURL)! }
    var path: String {
        switch self {
        case .fetchMonthly: return "/api/journeys/monthly"
        case .fetchDailyReport: return "/api/journeys/daily-report"
        }
    }
    var method: Moya.Method { .get }
    var task: Task {
        switch self {
        case .fetchMonthly(let year, let month):
            return .requestParameters(
                parameters: ["year": year, "month": month],
                encoding: URLEncoding.queryString
            )
        case .fetchDailyReport(let date):
            return .requestParameters(
                parameters: ["date": date],
                encoding: URLEncoding.queryString
            )
        }
    }
    var headers: [String: String]? {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(KeychainService.shared.loadToken() ?? "")"
        ]
    }
}

/// GET /api/journeys/monthly 응답의 data 배열 요소
struct MonthlyJourneyItemDTO: Decodable {
    let date: String
    let completedCount: Int
}

/// GET /api/journeys/daily-report 응답의 data
/// - journeyDay: 해당 날짜가 여정의 몇 일차인지 (1, 2, 3, …). 백엔드에서 내려주면 제목/그래프에 사용
struct DailyReportDataDTO: Decodable {
    let journeyId: Int
    let goal: String
    let journeyDay: Int?      // 여정 N일차 (API에서 제공 시 사용)
    let day1Rate: Double?
    let day2Rate: Double?
    let day3Rate: Double?
    let totalRate: Double?
    let completedRoutineCount: Int
    let recordContent: String?
    let routines: [DailyReportRoutineItemDTO]?
}

struct DailyReportRoutineItemDTO: Decodable {
    let routineId: Int
    let content: String
    let status: String
}

// MARK: - History Journey Report Model
struct HistoryJourneyReport {
    let date: Date
    let goal: String
    /// 여정 N일차 (API daily-report의 journeyDay). nil이면 미표시
    let journeyDay: Int?
    /// Day1/Day2/Day3 실행률 (API). 성장 추이 그래프에 사용
    let day1Rate: Double?
    let day2Rate: Double?
    let day3Rate: Double?
    let totalRate: Double?
    /// 여정 기록 텍스트 (API daily-report의 recordContent)
    let recordContent: String?
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
    case pending
    
    var displayText: String {
        switch self {
        case .completed:
            return "완료"
        case .postponed:
            return "미룸"
        case .pending:
            return "진행중"
        }
    }
}

@MainActor
class HistoryViewModel: ObservableObject {
    /// 날짜별 루틴 달성 개수 (GET /api/journeys/monthly 로 채움)
    @Published var routineCompletionCount: [Date: Int] = [:]
    
    /// 날짜별 리포트 (GET /api/journeys/daily-report + 더미)
    @Published var journeyReports: [Date: HistoryJourneyReport] = [:]
    
    /// 일일 리포트 API 로딩 중
    @Published var isLoadingDailyReport: Bool = false
    
    private let networkManager = DefaultNetworkManager<HistoryAPI>()
    private let calendar = Calendar.current
    
    private static let monthlyDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        return f
    }()
    
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
        
        // 테스트용 더미 데이터 (달력 점 + 리포트). 실제 연동 시 loadMonth() API가 해당 월을 덮어씀
        // setupExampleData()
        // setupExampleReports()
        
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
    
    /// 해당 월의 루틴 수행 개수를 API로 불러와 달력 점에 반영
    func loadMonth(_ date: Date) {
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        networkManager.request(
            target: .fetchMonthly(year: year, month: month),
            decodingType: [MonthlyJourneyItemDTO].self
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self.applyMonthlyData(list, year: year, month: month)
                case .failure(let error):
                    print("❌ loadMonth failed: \(error)")
                }
            }
        }
    }
    
    /// API 응답으로 해당 월의 routineCompletionCount 갱신 (해당 월 기존 키 제거 후 추가)
    private func applyMonthlyData(_ list: [MonthlyJourneyItemDTO], year: Int, month: Int) {
        let toRemove = routineCompletionCount.keys.filter { date in
            calendar.component(.year, from: date) == year && calendar.component(.month, from: date) == month
        }
        for key in toRemove {
            routineCompletionCount.removeValue(forKey: key)
        }
        for item in list {
            guard let date = Self.monthlyDateFormatter.date(from: item.date) else { continue }
            let dateKey = calendar.startOfDay(for: date)
            routineCompletionCount[dateKey] = item.completedCount
        }
    }
    
    /// 해당 날짜의 일일 리포트 API 호출 후 journeyReports 반영
    func loadDailyReport(for date: Date) {
        let dateKey = calendar.startOfDay(for: date)
        if dateKey > calendar.startOfDay(for: Date()) {
            return
        }
        let dateString = Self.monthlyDateFormatter.string(from: dateKey)
        isLoadingDailyReport = true
        networkManager.request(
            target: .fetchDailyReport(date: dateString),
            decodingType: DailyReportDataDTO.self
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoadingDailyReport = false
                switch result {
                case .success(let dto):
                    print("📊 [DailyReport] Rates - Day1: \(String(describing: dto.day1Rate)), Day2: \(String(describing: dto.day2Rate)), Day3: \(String(describing: dto.day3Rate)), Total: \(String(describing: dto.totalRate))")
                    let hasRecords = dto.completedRoutineCount > 0 || !(dto.routines?.isEmpty ?? true)
                    if hasRecords {
                        let report = self.mapDailyReportDTO(dto, date: dateKey)
                        self.journeyReports[dateKey] = report
                    } else {
                        // 루틴 실행 기록이 없으면 리포트 미표시
                        self.journeyReports[dateKey] = nil
                    }
                case .failure(let error):
                    print("❌ loadDailyReport failed: \(error)")
                }
            }
        }
    }
    
    /// API 달성률이 0~100(%)으로 오면 0.0~1.0으로 변환 (그래프 Y축은 0.0~1.0 기준)
    private func normalizeRate(_ value: Double?) -> Double? {
        guard let v = value else { return nil }
        if v > 1.0 { return min(1.0, max(0, v / 100)) }
        return min(1.0, max(0, v))
    }

    private func mapDailyReportDTO(_ dto: DailyReportDataDTO, date: Date) -> HistoryJourneyReport {
        let isToday = Calendar.current.isDateInToday(date)
        
        let routines: [HistoryRoutineReport] = (dto.routines ?? []).enumerated().map { index, item in
            let statusString = item.status.uppercased()
            let status: HistoryRoutineStatus
            
            if statusString.contains("COMPLETED") || statusString.contains("완료") {
                status = .completed
            } else if statusString.contains("POSTPONED") || statusString.contains("미룸") {
                status = .postponed
            } else {
                // 그 외 상태 (WAITING 등)
                if isToday {
                    status = .pending
                } else {
                    // 과거 날짜는 미룸(실패) 처리
                    status = .postponed
                }
            }

            // 루틴 ID를 서버 ID(25, 26, 27...) 대신 순서대로 1, 2, 3...으로 변환
            return HistoryRoutineReport(id: index + 1, name: item.content, status: status)
        }
        return HistoryJourneyReport(
            date: date,
            goal: dto.goal,
            journeyDay: dto.journeyDay,
            day1Rate: normalizeRate(dto.day1Rate),
            day2Rate: normalizeRate(dto.day2Rate),
            day3Rate: normalizeRate(dto.day3Rate),
            totalRate: normalizeRate(dto.totalRate),
            recordContent: dto.recordContent,
            routines: routines
        )
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
        
        // 테스트용 여정 목표 목록
        let exampleGoals = [
            "건강한 생활 만들기",
            "규칙적인 운동 습관 들이기",
            "아침 기상 루틴 지키기",
            "매일 독서 30분",
            "수면 패턴 개선하기"
        ]
        // 테스트용 루틴 이름 목록 (3개씩 묶어서 사용)
        let exampleRoutineNames = [
            ["아침 스트레칭", "물 8잔 마시기", "저녁 산책"],
            ["오전 운동 20분", "점심 식사 정해진 시간", "저녁 독서"],
            ["7시 기상", "아침 식사 챙겨 먹기", "23시 취침"],
            ["요가 15분", "영양제 복용", "일기 쓰기"],
            ["명상 10분", "물 2L 마시기", "스크린타임 1시간 이내"]
        ]
        
        for i in 0..<31 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dateKey = calendar.startOfDay(for: date)
                
                if let completionCount = routineCompletionCount[dateKey] {
                    let clampedCount = max(0, min(completionCount, 3))
                    let goalIndex = i % exampleGoals.count
                    let routineSetIndex = i % exampleRoutineNames.count
                    let names = exampleRoutineNames[routineSetIndex]
                    let routines: [HistoryRoutineReport] = (0..<3).map { idx in
                        let status: HistoryRoutineStatus = idx < clampedCount ? .completed : .postponed
                        let name = idx < names.count ? names[idx] : "루틴 \(idx + 1)"
                        return HistoryRoutineReport(id: idx + 1, name: name, status: status)
                    }
                    
                    journeyReports[dateKey] = HistoryJourneyReport(
                        date: date,
                        goal: exampleGoals[goalIndex],
                        journeyDay: nil,
                        day1Rate: nil,
                        day2Rate: nil,
                        day3Rate: nil,
                        totalRate: nil,
                        recordContent: nil,
                        routines: routines
                    )
                }
            }
        }
    }
}
