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
    @Published var continueJourneyErrorMessage: String?
    @Published var isReflectionSaved: Bool = false
    
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

    var allRoutinesSettled: Bool {
        !routines.isEmpty && routines.allSatisfy { $0.isCompleted || $0.isDelayed }
    }

    var reflectionButtonTitle: String {
        isReflectionSaved ? "기록 수정하기" : "여정 기록하기"
    }

    init() {
        fetchHomeData()
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
            journeyId: data.journey.journeyId,
            loopId: data.journey.journeyOrder,      // n번째 여정
            currentDay: data.journey.journeyDate,   // n일차 여정
            totalJourney: data.todayProgress.totalCount,
            completedJourney: data.todayProgress.completedCount,
            todayRoutine: data.routines.count,
            todayRoutineCount: data.todayProgress.completedCount,
            yesterdayRoutineCount: 0
        )
        // SessionStore에 현재 여정 ID 업데이트
        DispatchQueue.main.async {
            // HomeViewModel은 SessionStore를 직접 참조하지 않으므로, HomeView의 onReceive 등으로 처리하거나
            // HomeViewModel이 SessionStore를 주입받아야 함.
            // 여기서는 HomeView.swift에서 viewModel.journeyInfo가 변경될 때 session.currentJourneyId를 업데이트하도록 수정.
        }
            
        // 루틴 리스트 매핑
        self.routines = data.routines.map { dto in
            let normalizedTime = formatNotificationTime(dto.notificationTime)
            return RoutineModel(
                id: dto.routineId,
                routineProgressId: dto.routineProgressId ?? 0,
                title: dto.content,
                time: "\(normalizedTime) 알림 예정",
                isCompleted: dto.isCompleted,
                isDelayed: dto.isDelayed,
                delayReason: "" // 필요 시 서버에서 확장하여 받아야 함
            )
        }
        self.isReflectionSaved = false
            
        // 전날 미완료 루틴 처리 모드 여부 체크 (targetDate로 전날 데이터인지 함께 판별)
        checkUncompletedRoutines(
            isNotReady: data.isNotReady ?? false,
            targetDate: data.targetDate
        )
    }
    
    private func checkUncompletedRoutines(isNotReady: Bool, targetDate: String?) {
        // 서버 플래그 + targetDate가 "오늘 이전 날짜"인 경우에만 전날 미완료 모드 활성화
        let shouldEnableUncompletedMode = isNotReady && isPastDate(targetDate)
        guard shouldEnableUncompletedMode else {
            self.hasUncompletedRoutines = false
            if self.activeFullSheet == .uncompletedRoutineAlert {
                self.activeFullSheet = nil
            }
            return
        }

        let hasUnsettledRoutine = self.routines.contains { !$0.isCompleted && !$0.isDelayed }
        self.hasUncompletedRoutines = hasUnsettledRoutine
        if hasUnsettledRoutine {
            self.activeFullSheet = .uncompletedRoutineAlert
        }
    }

    private func isPastDate(_ rawDate: String?) -> Bool {
        guard let rawDate, !rawDate.isEmpty else { return false }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        guard let parsedDate = formatter.date(from: rawDate) else { return false }

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let targetStart = calendar.startOfDay(for: parsedDate)
        return targetStart < todayStart
    }

    private func formatNotificationTime(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.split(separator: ":")
        if parts.count >= 2 {
            return "\(parts[0]):\(parts[1])"
        }
        return trimmed
    }
    
    // MARK: - 루틴 완료 처리 (인증 버튼 클릭 시 호출)
    func completeRoutine(at index: Int) {
        guard index < routines.count else { return }
        guard !routines[index].isCompleted, !routines[index].isDelayed else { return }
        routines[index].isCompleted = true
            
        if var info = journeyInfo {
            // 오늘 완료 수를 루틴 상태에서 다시 계산해 이중 증가를 방지
            let completedCount = routines.filter(\.isCompleted).count
            info.todayRoutineCount = min(completedCount, info.todayRoutine)
                
            self.journeyInfo = info // 변경된 정보 반영
                
            // 3일 여정의 마지막 날(currentDay == 3)에 오늘 루틴을 모두 완료했을 때만 종료 팝업 노출
            let isLastJourneyDay = info.currentDay >= 3
            let isTodayRoutinesCompleted = info.todayRoutine > 0 && info.todayRoutineCount == info.todayRoutine
            if isLastJourneyDay && isTodayRoutinesCompleted {
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

    func updateDelayReason(at index: Int, reason: String) {
        let realIndex = index - 1
        guard realIndex >= 0 && realIndex < routines.count else { return }
        routines[realIndex].delayReason = reason
    }
    
    private func checkAllRoutinesSettled() {
        let allSettled = routines.allSatisfy { $0.isCompleted || $0.isDelayed }
        if allSettled && hasUncompletedRoutines {
            // 전날 미완료 루틴의 미루기 입력이 모두 끝난 상태.
            // 모드 해제와 오늘 데이터 반영은 recordButton("미완료 루틴 미루기") 탭 시점에 fetchHomeData()로 수행한다.
            return
        }
    }
    

    // MARK: - 비즈니스 로직

    func selectRoutine(at index: Int) {
        self.selectedRoutine = routines[index]
    }

    func completeSelectedRoutine() {
        guard let selectedRoutine else { return }
        guard let index = routines.firstIndex(where: { $0.id == selectedRoutine.id }) else { return }
        completeRoutine(at: index)
    }

    struct ContinueJourneyContext {
        let routines: [RoutineCoach]
        let goal: String
    }

    func continueJourneyAndPrepareRoutineCoach(
        completion: @escaping (Result<ContinueJourneyContext, NetworkError>) -> Void
    ) {
        guard let journeyId = journeyInfo?.journeyId, journeyId > 0 else {
            completion(.failure(.unknown))
            return
        }

        isLoading = true
        continueJourneyErrorMessage = nil

        networkManager.request(
            target: .continueJourney(journeyId: journeyId),
            decodingType: JourneyContinueData.self
        ) { [weak self] continueResult in
            guard let self else { return }
            switch continueResult {
            case .success:
                self.networkManager.request(
                    target: .fetchCurrentJourney,
                    decodingType: HomeDataDetail.self
                ) { [weak self] fetchResult in
                    guard let self else { return }
                    DispatchQueue.main.async {
                        self.isLoading = false
                        switch fetchResult {
                        case .success(let data):
                            self.updateUI(with: data)
                            completion(.success(.init(
                                routines: self.routinesForCoaching,
                                goal: self.goalTitle
                            )))
                        case .failure(let error):
                            self.continueJourneyErrorMessage = error.localizedDescription
                            completion(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.continueJourneyErrorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
    }

    func resetForNewOnboarding() {
        activeFullSheet = nil
        hasUncompletedRoutines = false
        selectedRoutine = nil
        journeyInfo = nil
        routines = []
        goalTitle = ""
        continueJourneyErrorMessage = nil
        isReflectionSaved = false
    }

    func markReflectionSaved() {
        isReflectionSaved = true
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
