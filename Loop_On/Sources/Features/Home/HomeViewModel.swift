//
//  HomeViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 1/20/26.
//

import Foundation
import Combine
import SwiftUI
import Moya

enum ActiveFullSheet: Identifiable {
    case camera
    case finishJourney
    case continueJourney
    case reflection
    case loading
    case delay
    case journeyReport
    case shareJourney
    case viewDelay
    case uncompletedRoutineAlert
    
    var id: Int {
        switch self {
        case .camera: return 1
        case .finishJourney: return 2
        case .continueJourney: return 3
        case .reflection: return 4
        case .loading: return 5
        case .delay: return 6
        case .journeyReport: return 7
        case .shareJourney: return 8
        case .viewDelay: return 9
        case .uncompletedRoutineAlert: return 10
        }
    }
}

class HomeViewModel: ObservableObject {
    private let provider = MoyaProvider<HomeAPI>()
    private var cancellables = Set<AnyCancellable>()
    private let networkManager = DefaultNetworkManager<HomeAPI>()
    
    // UI 상태 관리
    @Published var journeyInfo: JourneyInfo?    // loop_id 및 진척도 정보 포함
    @Published var routines: [RoutineModel] = []
    @Published var todayRoutineCount: Int = 0 // 오늘 완료한 루틴 개수 추적
    @Published var isLoading: Bool = false
    
    // 팝업 및 시트 제어
    @Published var activeFullSheet: ActiveFullSheet?
    @Published var isShowingDelayPopup: Bool = false    // 미루기 팝업 상태 변수
    @Published var isShowingFinishPopup: Bool = false
    @Published var isJourneyCreated: Bool = false
    
    // 목표 저장 변수
    @Published var goalTitle: String = ""
    
    @Published var hasUncompletedRoutines: Bool = false // 전날 미완료 루틴이 있는지 여부를 따지는 상태 변수
    
    // 선택된 루틴 정보
    var selectedRoutine: RoutineModel?
    var selectedRoutineIndex: Int {
        guard let selected = selectedRoutine else { return 1 }
        return (routines.firstIndex(where: { $0.id == selected.id }) ?? 0) + 1
    }
    
    var routinesForCoaching: [RoutineCoach] {
        routines.enumerated().map { index, model in
            RoutineCoach(
                index: index + 1,
                name: model.title,
                // RoutineModel의 time(String)을 Date로 변환하기 어려우면 현재 시간을 기본값으로 사용
                alarmTime: Date()
            )
        }
    }

    init() {
//        fetchHomeData()
    }

    // MARK: - API 통신 (Mock)
    func fetchHomeData() {
        self.isLoading = true
            
        networkManager.request(
            target: .fetchCurrentJourney,
            decodingType: HomeDataDetail.self
        ) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let data):
                    // 성공 시 data는 HomeDataDetail 타입
                    self.updateUI(with: data)

                case .failure(let error):
                    print("API Error:", error.localizedDescription)
                }
            }
        }
    }
        
    private func updateUI(with data: HomeDataDetail) {
        // 목표 타이틀 업데이트
        self.goalTitle = data.journey.goal
            
        // 여정 정보 매핑 (journeyOrder와 journeyDate 활용)
        self.journeyInfo = JourneyInfo(
            loopId: data.journey.journeyOrder,      // n번째 여정
            currentDay: data.journey.journeyDate,   // n일차 여정
            totalJourney: data.todayProgress.totalCount,
            completedJourney: data.todayProgress.completedCount,
            todayRoutine: data.routines.count,
            todayRoutineCount: data.todayProgress.completedCount,
            yesterdayRoutineCount: 0
        )
            
        // 루틴 리스트 매핑
        self.routines = data.routines.map { dto in
            RoutineModel(
                id: dto.routineId,
                title: dto.content,
                time: "\(dto.notificationTime) 알림 예정",
                isCompleted: dto.status == "COMPLETED",
                isDelayed: dto.status == "DELAYED",
                delayReason: "" // 필요 시 서버에서 확장하여 받아야 함
            )
        }
            
        // 상태 체크
        checkUncompletedRoutines()
    }
    
    private func checkUncompletedRoutines() {
        let hasUnsettledRoutine = self.routines.contains { !$0.isCompleted && !$0.isDelayed }
            
        if hasUnsettledRoutine {
            self.hasUncompletedRoutines = true
            self.activeFullSheet = .uncompletedRoutineAlert
        } else {
            self.hasUncompletedRoutines = false
        }
    }
//    func fetchHomeData() {
//        self.isLoading = true
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            // 더미 데이터 설정
//            let mockDTO = HomeDataResponseDTO(
//                loopId: 1,
//                title: "건강한 생활 만들기",
//                currentDay: 3, // 현재 1일차
//                totalJourney: 3,
//                completedJourney: 2,
//                todayRoutine: 3,       // 목표 개수
//                todayRoutineCount: 0,  // 오늘 시작 시점은 0
//                yesterdayRoutineCount: 3, // 어제 3개 중 2개만 완료한 상황 가정
//                routines: [
//                    RoutineDTO(id: 101, title: "아침에 일어나 물 한 컵 마시기", alarmTime: "08:00", isCompleted: false, isDelayed: false, delayReason: "컨디션이 좋지 않아요"),
//                    RoutineDTO(id: 102, title: "낮 시간에 몸 움직이기", alarmTime: "13:00", isCompleted: false, isDelayed: false, delayReason: "컨디션이 좋지 않아요"),
//                    RoutineDTO(id: 103, title: "정해진 시간에 침대에 눕기", alarmTime: "23:00", isCompleted: false, isDelayed: false, delayReason: "컨디션이 좋지 않아요")
//                ]
//            )
//                
//            // totalCount를 루틴 개수(3)가 아닌, 전체 여정 기간(예: 3일)으로 설정
//            self.journeyInfo = JourneyInfo(
//                loopId: mockDTO.loopId,
//                currentDay: mockDTO.currentDay,
//                totalJourney: 3, // 프로그래스 바의 총 칸 수
//                completedJourney: 2,  // 시작 시 완료된 일수
//                todayRoutine: 3,
//                todayRoutineCount: 0,
//                yesterdayRoutineCount: 3
//            )
//                
//            self.routines = mockDTO.routines.map {
//                RoutineModel(id: $0.id, title: $0.title, time: "\($0.alarmTime) 알림 예정", isCompleted: $0.isCompleted, isDelayed: $0.isDelayed, delayReason: $0.delayReason)
//            }
//            
//            // 미완료 루틴 플래그 판단 로직
//            // 완료된 루틴 개수가 총 루틴 개수보다 적으면 미처리된 것이 있다고 판단
//            let hasUnsettledRoutine = self.routines.contains { !$0.isCompleted && !$0.isDelayed }
//            
//            if hasUnsettledRoutine {
//            // 미처리된 루틴이 있을 때만 미완료 모드 활성화 및 팝업 노출
//                self.hasUncompletedRoutines = true
//                self.activeFullSheet = .uncompletedRoutineAlert
//            } else {
//                // 모든 루틴이 '완료' 혹은 '미루기'로 처리되었다면 팝업을 띄우지 않음
//                self.hasUncompletedRoutines = false
//            }
//            
//            self.isLoading = false
//            self.goalTitle = mockDTO.title
//        }
//    }
    
    // MARK: - 루틴 완료 처리 (인증 버튼 클릭 시 호출)
    func completeRoutine(at index: Int) {
        guard index < routines.count else { return }
        routines[index].isCompleted = true
            
        if var info = journeyInfo {
            // 완료 버튼 클릭 시 카운트 1 증가
            info.todayRoutineCount += 1
                
            // 오늘 목표를 달성했으면 완주 일수(completedJourney) 1 증가
            if info.todayRoutineCount == info.todayRoutine {
                info.completedJourney += 1
            }
                
            self.journeyInfo = info // 변경된 정보 반영
                
            // 전체 여정의 마지막 날까지 다 채웠을 때 종료 팝업 (기존 로직)
            if info.completedJourney == info.totalJourney {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.activeFullSheet = .finishJourney
                }
            }
        }
    }
    
    // 루틴 미루기 완료 처리
    func delayRoutine(at index: Int, reason: String) {
        let realIndex = index - 1
        guard realIndex >= 0 && realIndex < routines.count else { return }
        
        routines[realIndex].isDelayed = true
        routines[realIndex].delayReason = reason // 선택한 사유 저장
        routines[realIndex].time = "00:00 알림 완료"
        
        // 모든 루틴이 '완료' 혹은 '미루기' 상태인지 확인
        checkAllRoutinesSettled()
    }
    
    private func checkAllRoutinesSettled() {
        let allSettled = routines.allSatisfy { $0.isCompleted || $0.isDelayed }
        if allSettled && hasUncompletedRoutines {
            // 모든 어제 루틴 처리가 끝났으므로 모드 해제 및 데이터 갱신
            self.hasUncompletedRoutines = false
            fetchTodayRoutines() // 오늘 루틴 불러오기 호출
        }
    }
    
    // 오늘 날짜의 새로운 루틴으로 리스트를 갱신하는 로직
    private func fetchTodayRoutines() {
        self.isLoading = true
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self = self else { return }
            
            // 서버에서 새로 받아온 오늘의 루틴 리스트
            let todayRoutines = [
                RoutineDTO(routineId: 201, routineProgressId: 10, content: "물 한 컵 마시기 (오늘)", notificationTime: "08:00", status: "IN_PROGRESS"),
                RoutineDTO(routineId: 202, routineProgressId: 11, content: "점심 산책하기 (오늘)", notificationTime: "13:00", status: "IN_PROGRESS"),
                RoutineDTO(routineId: 203, routineProgressId: 12, content: "독서 30분 하기 (오늘)", notificationTime: "22:00", status: "IN_PROGRESS")
            ]
                
            // 리스트 업데이트
            self.routines = todayRoutines.map { dto in
                RoutineModel(
                    id: dto.routineId,
                    title: dto.content,
                    time: "\(dto.notificationTime) 알림 예정",
                    isCompleted: dto.isCompleted,
                    isDelayed: dto.isDelayed,
                    delayReason: ""
                )
            }
                
            // 오늘 진행도 초기화
            if var info = self.journeyInfo {
                info.todayRoutineCount = 0
                self.journeyInfo = info
            }
                
            self.isLoading = false
            print("오늘 날짜의 새로운 루틴으로 갱신 완료!")
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
