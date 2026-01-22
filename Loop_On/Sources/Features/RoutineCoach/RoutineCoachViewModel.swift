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
    
    init() {
        // 초기 더미 데이터 세팅 (이미지와 동일하게 3개)
        self.routines = [
            RoutineCoach(index: 1, name: "루틴 이름", alarmTime: Date()),
            RoutineCoach(index: 2, name: "루틴 이름", alarmTime: Date()),
            RoutineCoach(index: 3, name: "루틴 이름", alarmTime: Date())
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
    }
    
    func startJourney() {
        // 여정 떠나기 로직
        print("여정 떠나기")
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
}
