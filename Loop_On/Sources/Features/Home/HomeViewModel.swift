//
//  HomeViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 1/20/26.
//

import Foundation
import SwiftUI

enum ActiveFullSheet: Identifiable {
    case camera
    case finishJourney
    case continueJourney
    case reflection
    case loading
    
    var id: Int {
        switch self {
        case .camera: return 1
        case .finishJourney: return 2
        case .continueJourney: return 3
        case .reflection: return 4
        case .loading: return 5
        }
    }
}

struct Routine: Identifiable {
    let id = UUID()
    let title: String
    let time: String
    var isCompleted: Bool = false
}


class HomeViewModel: ObservableObject {
    // 실제 데이터는 나중에 API에서 받아올 수 있도록 구성
    @Published var routines: [Routine] = [
        Routine(title: "아침에 일어나 물 한 컵 마시기", time: "08:00 알림 예정"),
        Routine(title: "낮 시간에 몸 움직이기", time: "13:00 알림 예정"),
        Routine(title: "정해진 시간에 침대에 눕기", time: "23:00 알림 예정")
    ]
    @Published var isShowingFinishPopup = false // 팝업 제어 변수
    @Published var isShowingContinuePopup = false
    @Published var isJourneyCreated = false // 여정 생성 완료 상태
    
    // 완료된 루틴 개수
    var completedCount: Int {
        routines.filter { $0.isCompleted }.count
    }
    
    // 전체 루틴 개수
    var totalCount: Int {
        routines.count
    }
    
    // 루틴 완료 처리 (인증 성공 시 호출)
    func completeRoutine(at index: Int) {
        guard index < routines.count else { return }
        routines[index].isCompleted = true
        
        if completedCount == totalCount {
            // 약간의 딜레이
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isShowingFinishPopup = true
            }
        }
        // 여기에 나중에 API POST 요청 등을 추가
    }
    
    // 새 여정 생성
    func createNewJourney() {
        // 여정 생성 시뮬레이션 (네트워크 통신 등)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // 2초 뒤 완료
            self.isJourneyCreated = true
        }
    }
    
    // 여정 초기화
    func resetJourneyStatus() {
        isJourneyCreated = false
    }
}


