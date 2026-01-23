//
//  HomeViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 1/20/26.
//

import Foundation
import Combine
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

class HomeViewModel: ObservableObject {
    // UI 상태 관리
    @Published var journeyInfo: JourneyInfo?    // loop_id 및 진척도 정보 포함
    @Published var routines: [RoutineModel] = []
    @Published var isLoading: Bool = false
    
    // 팝업 및 시트 제어
    @Published var activeFullSheet: ActiveFullSheet?
    @Published var isShowingDelayPopup: Bool = false    // 미루기 팝업 상태 변수
    @Published var isShowingFinishPopup: Bool = false
    @Published var isJourneyCreated: Bool = false
    
    // 선택된 루틴 정보
    var selectedRoutine: RoutineModel?
    var selectedRoutineIndex: Int {
        guard let selected = selectedRoutine else { return 1 }
        return (routines.firstIndex(where: { $0.id == selected.id }) ?? 0) + 1
    }

    init() {
        fetchHomeData()
    }

    // MARK: - API 통신 (Mock)
    func fetchHomeData() {
        self.isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 더미 데이터 설정
            let mockDTO = HomeDataResponseDTO(
                loopId: 1,
                title: "목표 건강한 생활 만들기",
                currentDay: 3, // 현재 1일차
                totalRoutines: 3,
                completedRoutines: 2,
                routines: [
                    RoutineDTO(id: 101, title: "아침에 일어나 물 한 컵 마시기", alarmTime: "08:00", isCompleted: false),
                    RoutineDTO(id: 102, title: "낮 시간에 몸 움직이기", alarmTime: "13:00", isCompleted: false),
                    RoutineDTO(id: 103, title: "정해진 시간에 침대에 눕기", alarmTime: "23:00", isCompleted: false)
                ]
            )
                
            // totalCount를 루틴 개수(3)가 아닌, 전체 여정 기간(예: 3일)으로 설정
            self.journeyInfo = JourneyInfo(
                loopId: mockDTO.loopId,
                currentDay: mockDTO.currentDay,
                totalCount: 3, // 프로그래스 바의 총 칸 수
                completedCount: 2  // 시작 시 완료된 일수
            )
                
            self.routines = mockDTO.routines.map {
                RoutineModel(id: $0.id, title: $0.title, time: "\($0.alarmTime) 알림 예정", isCompleted: $0.isCompleted)
            }
            self.isLoading = false
        }
    }
    
    // MARK: - 루틴 완료 처리 (인증 버튼 클릭 시 호출)
    func completeRoutine(at index: Int) {
        guard index < routines.count else { return }
                
        // 해당 루틴 상태 업데이트
        routines[index].isCompleted = true
                
        if let currentInfo = journeyInfo {
            // 오늘 루틴이 모두 완료되었는지 확인
            let isAllTodayCompleted = routines.allSatisfy { $0.isCompleted }
                
            // 완주율(프로그래스 바) 업데이트 로직
            // 모든 루틴 완료 시 현재 일차(currentDay)를 완료된 일수로 설정
            let updatedCompletedCount = isAllTodayCompleted ? currentInfo.currentDay : (currentInfo.currentDay - 1)
                
            self.journeyInfo = JourneyInfo(
                loopId: currentInfo.loopId,
                currentDay: currentInfo.currentDay,
                totalCount: currentInfo.totalCount,
                completedCount: updatedCompletedCount
            )
                
            // 종료 팝업 호출 조건 변경
            // 오늘 루틴을 다 끝냈고, 동시에 '전체 여정의 마지막 날'일 때만 종료 팝업을 띄움
            if isAllTodayCompleted && updatedCompletedCount == currentInfo.totalCount {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.activeFullSheet = .finishJourney
                }
            }
        }
    }

    // MARK: - 비즈니스 로직

    func selectRoutine(at index: Int) {
        self.selectedRoutine = routines[index]
    }
    
    func createNewJourney() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isJourneyCreated = true
        }
    }

    func resetJourneyStatus() {
        isJourneyCreated = false
    }
}
