//
//  RoutineCoachViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 1/21/26.
//

import Foundation
import Combine
import SwiftUI

struct RoutineCoach: Identifiable {
    let id = UUID()
    var index: Int
    var name: String
    var alarmTime: Date
}

class RoutineCoachViewModel: ObservableObject {
    @Published var isLoading = false // 로딩 상태 추가
    @Published var isJourneyStarted = false // HomeView로 이동하기 위한 트리거
    @Published var routines: [RoutineCoach] = []
    @Published var isShowingTimePicker = false // 팝업 표시 여부
    @Published var selectedRoutineIndex: Int? // 현재 수정 중인 루틴의 인덱스
    @Published var tempSelectionDate = Date() // 피커에서 임시로 선택 중인 시간
    @Published var isEditing: Bool = false // 편집 모드 상태
    
    
    // 이 값들은 이전 단계에서 받아왔거나 설정된 값이라고 가정
    var loop_id: Int = 2 // 예: "두 번째 여정" -> 2
    var goal_text: String = "건강한 생활 습관 만들기"
    var selected_insights: [String] = ["수면 개선", "식단 관리"]
    
    // 루틴 이름 수정 관련 변수
    @Published var isShowingNameEditor = false
    @Published var newRoutineName = ""
    private var editingIndex: Int?
    
    init() {
        // 초기 더미 데이터 세팅 (이미지와 동일하게 3개)
        self.routines = [
            RoutineCoach(index: 1, name: "루틴 이름", alarmTime: Date()),
            RoutineCoach(index: 2, name: "루틴 이름", alarmTime: Date()),
            RoutineCoach(index: 3, name: "루틴 이름", alarmTime: Date()),
            RoutineCoach(index: 4, name: "루틴 이름", alarmTime: Date()),
        ]
    }
    
    func regenerateRoutines() {
        // 루틴 다시 생성 로직
        print("루틴 다시 생성")
    }
    
    func editRoutinesDirectly() {
        isEditing = true
    }

    func finishEditing() {
        isEditing = false
        // 여기서 변경된 내용을 서버에 저장하는 API를 호출.
    }
        
    func deleteRoutine(at index: Int) {
        routines.remove(at: index)
        // 삭제 후 인덱스 재정렬 로직.
        reorderRoutines()
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
    
//    func startJourney() {
//        // 여정 떠나기 로직
//        isLoading = true
//                
//        // 서버 통신을 시뮬레이션. (API 없이 로직 구현)
//        Task {
//            // 실제 서버에 다녀오는 것처럼 1.5초간 대기
//            try? await Task.sleep(nanoseconds: 3_000_000_000)
//            
//            // 작업이 끝난 후 메인 스레드에서 로딩을 해제합니다.
//            await MainActor.run {
//                withAnimation {
//                    self.isLoading = false
//                }
//                print("여정 시작 데이터 처리 완료!")
//                // 여기서 다음 화면으로 넘어가는 로직을 실행
//            }
//        }
        
        // 로딩 시작
//        isLoading = true
//                
//        // 서버 통신 및 데이터 처리 (비동기)
//        Task {
//            do {
//                // 가상의 서버 통신 시간 (예: 2초)
//                try await Task.sleep(nanoseconds: 2_000_000_000)
//                
//                // 성공 시 로딩 종료 및 다음 화면 이동 로직
//                await MainActor.run {
//                    isLoading = false
//                    print("여정 시작 성공")
//                    // 네비게이션 로직 등을 여기에 추가
//                }
//            } catch {
//                await MainActor.run {
//                    isLoading = false
//                    print("여정 시작 실패")
//                }
//            }
//        }
//    }
    
    func startJourney() {
            isLoading = true
            
            Task {
                do {
                    // 서버에 저장할 데이터 패키징
                    let journeyData: [String: Any] = [
                        "loop_id": loop_id,
                        "goal_text": goal_text,
                        "selected_insights": selected_insights,
                        "routines": routines.map { [
                            "index": $0.index,
                            "name": $0.name,
                            "alarm_time": formatDateForServer($0.alarmTime)
                        ]}
                    ]
                    
                    print("서버로 전송할 데이터: \(journeyData)")
                    
                    // 가상 API 통신 (실제 API 명세서 나오면 이 부분을 교체)
                    try await saveJourneyToServer(data: journeyData)
                    
                    // 성공 시 메인 스레드에서 화면 전환 트리거
                    await MainActor.run {
                        withAnimation {
                            self.isLoading = false
                            self.isJourneyStarted = true // HomeView 이동 신호
                        }
                    }
                } catch {
                    await MainActor.run {
                        self.isLoading = false
                        // 에러 처리 로직 (Alert 등)
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
