//
//  RoutineCoachViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 1/21/26.
//

import Foundation
import Combine
import SwiftUI

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
    @Published var isLoading = false // 로딩 상태 추가
    @Published var isJourneyStarted = false // HomeView로 이동하기 위한 트리거
    @Published var routines: [RoutineCoach] = []
    @Published var isShowingTimePicker = false // 팝업 표시 여부
    @Published var selectedRoutineIndex: Int? // 현재 수정 중인 루틴의 인덱스
    @Published var tempSelectionDate = Date() // 피커에서 임시로 선택 중인 시간
    @Published var isEditing: Bool = false // 편집 모드 상태
    @Published var isRegenerating: Bool = false // 재생성 모드 상태
    
    
    // 이 값들은 이전 단계에서 받아왔거나 설정된 값이라고 가정
    @Published var loop_id: Int = 2 // 예: "두 번째 여정" -> 2
    var goal_text: String = "건강한 생활 습관 만들기"
    var selected_insights: [String] = ["수면 개선", "식단 관리"]
    
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
        // 해당 루틴의 데이터를 랜덤하게 변경하거나 서버에서 새로 받아옴
        print("DEBUG: \(index + 1)번 루틴 재생성 요청")
        // routines[index].name = "새로 생성된 루틴"
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
        
        // 현재 화면에 표시된 routines 데이터를 API 형식으로 변환
        let routineRequests = routines.map { routine in
            RoutineContentRequest(
                content: routine.name,
                notificationTime: formatDateForServer(routine.alarmTime)
            )
        }
        
        // 요청 객체 생성 (전달받은 journeyId가 필요함)
        // ViewModel init 시 journeyId를 함께 받도록 수정되어 있어야 합니다.
        let request = RoutineCreateRequest(
            journeyId: self.loop_id, // 저장된 journeyId 사용
            routines: routineRequests
        )

        // 실제 API 호출
        networkManager.request(
            target: .createRoutines(request: request),
            decodingType: RoutineCreateResponse.self
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case .success(let response):
                    print("루틴 서버 저장 성공: \(response.message)")
                    self.isLoading = false
                    self.isJourneyStarted = true // HomeView로 이동
                case .failure(let error):
                    print("루틴 저장 실패: \(error.localizedDescription)")
                    self.isLoading = false
                    // 에러 처리 알럿 로직 추가 가능
                }
            }
        }
    }
    
    // API 통신 시뮬레이션
    private func saveJourneyToServer(data: [String: Any]) async throws {
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2초 대기
        // 실제 통신 시에는 여기서 URLSession 등을 사용
    }
        
    private func formatDateForServer(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
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
