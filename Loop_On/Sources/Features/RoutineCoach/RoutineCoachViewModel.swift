//
//  RoutineCoachViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 1/21/26.
//

import Foundation
import Combine
import SwiftUI
import Moya

struct RoutineCoach: Identifiable, Hashable, Codable {
    var id = UUID()
    var index: Int
    var name: String
    var alarmTime: Date

    init(index: Int, name: String, alarmTime: Date) {
        self.id = UUID()
        self.index = index
        self.name = name
        self.alarmTime = alarmTime
    }
}

class RoutineCoachViewModel: ObservableObject {
    @Published var journeyOrder: Int = 0 // API로 받아올 순서 값 (몇번째 여정인지)
    @Published var errorMessage: String? // 에러 메시지 변수
    @Published var isLoading = false // 로딩 상태 추가
    @Published var isJourneyStarted = false // HomeView로 이동하기 위한 트리거
    @Published var routines: [RoutineCoach] = []
    @Published var isShowingTimePicker = false // 팝업 표시 여부
    @Published var selectedRoutineIndex: Int? // 현재 수정 중인 루틴의 인덱스
    @Published var tempSelectionDate = Date() // 피커에서 임시로 선택 중인 시간
    @Published var isEditing: Bool = false // 편집 모드 상태
    @Published var isRegenerating: Bool = false // 재생성 모드 상태
    @Published var regeneratingRoutineIDs: Set<UUID> = []
    
    
    // 이 값들은 이전 단계에서 받아왔거나 설정된 값이라고 가정
    @Published var loop_id: Int = 2 // 예: "두 번째 여정" -> 2
    var goal_text: String = "건강한 생활 습관 만들기"
    var category: String = "ROUTINE"
    var selected_insights: [String] = []
    
    // 루틴 이름 수정 관련 변수
    @Published var isShowingNameEditor = false
    @Published var newRoutineName = ""
    private var editingIndex: Int?
    
    private let networkManager = DefaultNetworkManager<OnboardingAPI>()
    
    init(initialRoutines: [RoutineCoach]) {
        if initialRoutines.isEmpty {
            // 데이터가 없을 경우에만 더미 데이터 사용
            self.routines = [
                RoutineCoach(index: 1, name: "루틴 이름", alarmTime: Date()),
                RoutineCoach(index: 2, name: "루틴 이름", alarmTime: Date()),
                RoutineCoach(index: 3, name: "루틴 이름", alarmTime: Date())
            ]
        } else {
            self.routines = initialRoutines
        }
    }
    
    // 순서 조회 API 호출 함수
//    func fetchJourneyOrder() {
//        print("DEBUG: 여정 순서 조회 API 호출 시작")
//        networkManager.request(
//            target: .getJourneyOrder,
//            decodingType: JourneyOrderResponse.self
//        ) { [weak self] result in
//            guard let self = self else { return }
//            _Concurrency.Task { @MainActor in
//                switch result {
//                case .success(let response):
//                    self.journeyOrder = response.data.order
//                case .failure(let error):
//                    self.errorMessage = error.localizedDescription
//                }
//            }
//        }
//    }
    func fetchJourneyOrder() {
        print("DEBUG: 여정 순서 조회 API 호출 시작") // 로그 추가
        networkManager.request(
            target: .getJourneyOrder,
            decodingType: JourneyOrderData.self
        ) { [weak self] result in
            guard let self = self else { return }
            _Concurrency.Task { @MainActor in
                switch result {
                case .success(let data):
                    print("DEBUG: API 성공 - 수령한 순서: \(data.order)") // 로그 추가
                    self.journeyOrder = data.order
                case .failure(let error):
                    print("DEBUG: API 실패 - 에러 내용: \(error.localizedDescription)") // 로그 추가
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // 루틴 다시 생성 버튼 클릭 시
    func regenerateRoutines() {
        isRegenerating = true
        // 필요 시 여기서 새로운 루틴 데이터를 서버나 로컬에서 받아오는 로직 추가
        print("재생성 모드 진입")
    }
        
    // 재생성 '확인' 버튼 클릭 시
    func confirmRegeneration() {
        isRegenerating = false
        // 확정된 루틴 데이터를 서버에 저장하거나 상태를 고정하는 로직
        print("재생성 루틴 확정")
    }
    
    func editRoutinesDirectly() {
        self.isEditing = true
    }

    func finishEditing() {
        print("DEBUG: 완료 버튼이 눌렸습니다!")
        
        self.isEditing = false
        // 여기서 변경된 내용을 서버에 저장하는 API를 호출.
        print("DEBUG: isEditing 상태가 \(self.isEditing)으로 변경되었습니다.")
    }
        
    func deleteRoutine(at index: Int) {
        routines.remove(at: index)
        // 삭제 후 인덱스 재정렬 로직.
        reorderRoutines()
    }
    
    func regenerateSingleRoutine(at index: Int) {
        guard routines.indices.contains(index) else { return }
        let routine = routines[index]
        guard !regeneratingRoutineIDs.contains(routine.id) else { return }

        let request = RoutineRegenerateRequest(
            originalGoal: sanitizeText(routine.name),
            mainGoal: sanitizeText(goal_text)
        )

        regeneratingRoutineIDs.insert(routine.id)
        errorMessage = nil
        print("DEBUG: \(index + 1)번 루틴 재생성 API 요청")

        networkManager.request(
            target: .regenerateRoutine(request: request),
            decodingType: RoutineRegenerateData.self
        ) { [weak self] result in
            guard let self else { return }
            _Concurrency.Task { @MainActor in
                defer { self.regeneratingRoutineIDs.remove(routine.id) }

                switch result {
                case .success(let data):
                    guard let targetIndex = self.routines.firstIndex(where: { $0.id == routine.id }) else { return }
                    let regeneratedText = self.sanitizeText(data.newGoal)
                    guard !regeneratedText.isEmpty else {
                        self.errorMessage = "재생성 결과가 비어 있습니다."
                        return
                    }
                    self.routines[targetIndex].name = regeneratedText
                    print("DEBUG: \(targetIndex + 1)번 루틴 재생성 성공 -> \(regeneratedText)")

                case .failure(let error):
                    self.errorMessage = "루틴 재생성에 실패했습니다. 잠시 후 다시 시도해주세요."
                    print("DEBUG: 루틴 재생성 실패 - \(error)")
                }
            }
        }
    }
    
    // MARK: - 루틴 삭제 및 자동 재정렬 (API 연동시 사용)
//        func deleteRoutine(at index: Int) {
//            let targetID = routines[index].id
//            let backupRoutines = routines // 실패 시 복구를 위한 스냅샷 저장
//
//            withAnimation(.spring()) {
//                // 해당 루틴 삭제
//                self.routines.remove(at: index)
//
//                // 루틴 번호 재정렬
//                self.reorderRoutines()
//            }
//
//            // 서버 반영 (비동기)
//            Task {
//                do {
//                    try await requestDeleteRoutineToServer(routineID: targetID)
//                    print("서버 삭제 및 재정렬 반영 성공")
//                } catch {
//                    // 서버 통신 실패 시 백업 데이터로 복구
//                    await MainActor.run {
//                        withAnimation {
//                            self.routines = backupRoutines
//                        }
//                    }
//                    print("서버 통신 실패로 인한 복구 실행")
//                }
//            }
//        }
    
    // 인덱스 번호를 1부터 다시 부여하는 로직
    private func reorderRoutines() {
        for i in 0..<routines.count {
            routines[i].index = i + 1
        }
    }
    
    func startJourney() {
        isLoading = true
        
        let sanitizedGoal = sanitizeText(goal_text)

        // 현재 화면에 표시된 routines 데이터를 API 형식으로 변환
        let routineRequests = routines.map { routine in
            RoutineContentRequest(
                content: sanitizeText(routine.name),
                time: formatDateForServer(routine.alarmTime)
            )
        }
        
        let selectedLoop = sanitizeText(selected_insights.first ?? (routines.first?.name ?? sanitizedGoal))
        let requestCategory = normalizedCategory(category)

        // 요청 객체 생성
        let request = RoutineCreateRequest(
            goal: sanitizedGoal,
            category: requestCategory,
            selectedLoop: selectedLoop,
            routines: routineRequests
        )
        
        if let encoded = try? JSONEncoder().encode(request),
           let requestBody = String(data: encoded, encoding: .utf8) {
            print("createRoutines request body: \(requestBody)")
        }

        // 실제 API 호출
        // 실패 시 서버의 raw 응답 body를 그대로 로그로 남겨 검증 메시지를 확인한다.
        networkManager.provider.request(.createRoutines(request: request)) { [weak self] result in
            guard let self else { return }
            _Concurrency.Task { @MainActor in
                switch result {
                case .success(let response):
                    if (200...299).contains(response.statusCode) {
                        print("루틴 서버 저장 성공")
                        self.isLoading = false
                        self.isJourneyStarted = true // HomeView로 이동
                    } else {
                        let rawBody = String(data: response.data, encoding: .utf8) ?? "<response body decode failed>"
                        print("루틴 저장 실패(status: \(response.statusCode))")
                        print("루틴 저장 실패 raw body: \(rawBody)")
                        self.errorMessage = "서버 오류 \(response.statusCode)"
                        self.isLoading = false
                    }
                case .failure(let moyaError):
                    print("루틴 저장 네트워크 실패: \(moyaError.localizedDescription)")
                    self.errorMessage = moyaError.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    // API 통신 시뮬레이션
    private func saveJourneyToServer(data: [String: Any]) async throws {
        try await _Concurrency.Task.sleep(nanoseconds: 2_000_000_000) // 2초 대기
        // 실제 통신 시에는 여기서 URLSession 등을 사용
    }
        
    private func formatDateForServer(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func normalizedCategory(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        switch trimmed.uppercased() {
        case "ROUTINE", "생활 루틴", "생활루틴":
            return "ROUTINE"
        case "SKILL", "역량 강화", "역량강화":
            return "GROWTH"
        case "MENTAL", "내면 관리", "내면관리":
            return "MENTAL"
        default:
            return trimmed
        }
    }
    
    private func sanitizeText(_ raw: String) -> String {
        let noMarkdown = raw
            .replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "__", with: "")
            .replacingOccurrences(of: "`", with: "")
        return noMarkdown.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func openTimePicker(for index: Int) {
        selectedRoutineIndex = index
        // 현재 루틴에 설정된 시간을 피커의 초기값으로 세팅
        tempSelectionDate = routines[index].alarmTime
        isShowingTimePicker = true
    }
        
    func saveSelectedTime() {
        if let index = selectedRoutineIndex {
            routines[index].alarmTime = tempSelectionDate
        }
        isShowingTimePicker = false
    }
    
    // 수정 팝업 열기
    func prepareEditName(for index: Int) {
        self.editingIndex = index
        self.newRoutineName = routines[index].name
        self.isShowingNameEditor = true
    }

    // 이름 저장 로직
    func updateRoutineName() {
        guard let index = editingIndex, !newRoutineName.isEmpty else { return }
        routines[index].name = newRoutineName
        isShowingNameEditor = false
    }
    
    // MARK: - 이름 수정 서버 반영
//        func updateRoutineName() {
//            guard let index = editingIndex, !newRoutineName.isEmpty else { return }
//
//            let oldName = routines[index].name // 실패 시 복구를 위한 백업
//            let targetID = routines[index].id
//            let updatedName = newRoutineName
//
//            // UI를 먼저 업데이트 (사용자 경험 개선)
//            routines[index].name = updatedName
//            isShowingNameEditor = false
//
//            // 서버 API 호출
//            Task {
//                do {
//                    try await requestUpdateNameToServer(routineID: targetID, name: updatedName)
//                    print("서버 이름 수정 성공")
//                } catch {
//                    // 실패 시 이전 이름으로 롤백
//                    await MainActor.run {
//                        self.routines[index].name = oldName
//                        // 유저에게 에러 알림 표시 로직 추가 가능
//                    }
//                    print("서버 이름 수정 실패: \(error)")
//                }
//            }
//        }

        // MARK: - 루틴 삭제 서버 반영
//        func deleteRoutine(at index: Int) {
//            let targetID = routines[index].id
//            let backupRoutines = routines // 실패 시 복구용 백업
//
//            // UI 선반영
//            withAnimation {
//                self.routines.remove(at: index)
//            }
//
//            Task {
//                do {
//                    try await requestDeleteRoutineToServer(routineID: targetID)
//                    print("서버 삭제 성공")
//                } catch {
//                    // 실패 시 복구
//                    await MainActor.run {
//                        self.routines = backupRoutines
//                    }
//                    print("서버 삭제 실패: \(error)")
//                }
//            }
//        }
    
    // MARK: - API 연동부 (주석 처리)
        /*
        private func requestUpdateNameToServer(routineID: UUID, name: String) async throws {
            // URL 설정
            // guard let url = URL(string: "https://api.loopon.com/routines/\(routineID)") else { return }
            
            // Request 생성 (Method: PATCH or PUT)
            // var request = URLRequest(url: url)
            // request.httpMethod = "PATCH"
            // request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // 바디 데이터 생성
            // let body = ["name": name]
            // request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            
            // 통신 실행
            // let (data, response) = try await URLSession.shared.data(for: request)
            // ... 서버 응답 코드 검증 ...
            
            // 현재는 시뮬레이션을 위해 1초 대기 후 종료
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
        
        private func requestDeleteRoutineToServer(routineID: UUID) async throws {
            // URL 설정 (Method: DELETE)
            // 통신 실행
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
        */
}
