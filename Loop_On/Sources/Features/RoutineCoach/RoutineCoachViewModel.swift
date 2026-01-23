//
//  RoutineCoachViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 1/21/26.
//

import Foundation
import Combine

struct RoutineCoach: Identifiable {
    let id = UUID()
    var index: Int
    var name: String
    var alarmTime: Date
}

class RoutineCoachViewModel: ObservableObject {
    @Published var routines: [RoutineCoach] = []
    @Published var isShowingTimePicker = false // 팝업 표시 여부
    @Published var selectedRoutineIndex: Int? // 현재 수정 중인 루틴의 인덱스
    @Published var tempSelectionDate = Date() // 피커에서 임시로 선택 중인 시간
    @Published var isEditing: Bool = false // 편집 모드 상태
    
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
//                // 1. 해당 루틴 삭제
//                self.routines.remove(at: index)
//                
//                // 2. 루틴 번호 재정렬 (루틴 1, 루틴 2, 루틴 3...)
//                self.reorderRoutines()
//            }
//            
//            // 3. 서버 반영 (비동기)
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
        // 여정 떠나기 로직
//        CommonLoadingView(
//            message: "2박 3일 여정으로 떠나고 있습니다.",
//            lottieFileName: "Loading 51 _ Monoplane"
//        )
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
