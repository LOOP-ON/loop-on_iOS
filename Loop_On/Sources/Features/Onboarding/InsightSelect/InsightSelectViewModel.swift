//
//  InsightSelectViewModel.swift
//  Loop_On
//
//  Created by 써니/김세은
//

import Foundation

struct InsightItem: Identifiable, Hashable {
    let id: UUID
    let title: String

    init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title
    }
}

@MainActor
final class InsightSelectViewModel: ObservableObject {
    var router: NavigationRouter?
    // API: 인사이트 선택 결과 저장/루프 생성 요청 매니저
    private let networkManager = DefaultNetworkManager<OnboardingAPI>()

    // 더미 데이터 (추후 GoalSelect 결과에 따라 goalTitle 주입/연동)
    @Published var goalTitle: String = "건강한 생활 만들기"
    // API: Step2에서 전달된 목표/카테고리 (TODO: 실제 값 주입)
    @Published var goalText: String = ""
    @Published var selectedCategory: String = ""

    @Published var insights: [InsightItem] = [
        .init(title: "생활 리듬 바꾸기"),
        .init(title: "기상 후 1시간 이내 아침 습관 만들기"),
        .init(title: "준비물 없는 행동으로 시작하기"),
        .init(title: "체력이 가장 많이 남아있는 시간대로 루틴 설정하기"),
        .init(title: "산책/스트레칭 등 가벼운 활동하기")
    ]

    @Published var selected: Set<InsightItem> = []
    @Published var isCreatingLoop: Bool = false
    @Published var errorMessage: String?
    

    init(goalText: String, selectedCategory: String, insights: [String]) {
        self.goalText = goalText
        self.selectedCategory = selectedCategory
            
        if !goalText.isEmpty {
            self.goalTitle = goalText
        }
            
        if !insights.isEmpty {
            self.insights = insights.map { InsightItem(title: $0) }
        }
    }

    /// 스펙: 0개도 허용할 경우 항상 활성
//    var canCreateLoop: Bool { true }
    var canCreateLoop: Bool {
        return selected.count >= 3
    }

    var selectedTitles: [String] {
        selected
            .map(\.title)
            .sorted()
    }

    func toggle(_ item: InsightItem) {
        if selected.contains(item) {
            selected.remove(item)
        } else {
            selected.insert(item)
        }
    }
    
    func convertToDate(_ timeString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: timeString) ?? Date()
    }
    
    func createLoop() {
        let selectedItems = Array(selected).prefix(3)
            
        let newRoutines = selectedItems.enumerated().map { index, item in
            RoutineCoach(
                index: index + 1,
                name: item.title,
                alarmTime: convertToDate("09:00")
            )
        }
            
        // Router를 통해 데이터를 RoutineCoach로 전달
        self.router?.push(.app(.routineCoach(
            routines: newRoutines,
            goal: self.goalText,
            category: self.selectedCategory,
            selectedInsights: selectedItems.map(\.title),
            showContinuationPopup: false
        )))
    }
    
//    func createLoop() {
//        // 선택된 인사이트들을 RoutineContentRequest 배열로 변환
//        let routineRequests = selected.map { item in
//            RoutineContentRequest(
//                content: item.title,
//                notificationTime: "09:00" // 기본값 혹은 사용자가 설정한 시간
//            )
//        }
//        
//        // 전체 요청 객체 생성 (journeyId는 현재 맥락에 맞는 ID 주입 필요)
//        let request = RoutineCreateRequest(
//            journeyId: self.journeyId,
//            routines: routineRequests
//        )
//
//        isCreatingLoop = true
//        errorMessage = nil
//
//        // 11번 API 호출
//        networkManager.request(target: .createRoutines(request: request), decodingType: RoutineCreateResponse.self) { [weak self] result in
//            guard let self else { return }
//            Task { @MainActor in
//                self.isCreatingLoop = false
//                switch result {
//                case .success(let response):
//                    // API 응답 데이터를 RoutineCoach 배열로 변환
//                    let newRoutines = response.data.routines.enumerated().map { index, detail in
//                        RoutineCoach(
//                            index: index + 1,
//                            name: detail.content, // 인사이트 내용이 루틴 이름으로 들어감
//                            alarmTime: self.convertToDate(detail.notificationTime) // "09:00" -> Date
//                        )
//                    }
//                    // 탭바의 HomeView로 이동하며 생성된 루틴 전달
//                    self.router?.push(.app(.routineCoach(routines: newRoutines)))
//                    
//                case .failure(let error):
//                    self.errorMessage = error.localizedDescription
//                }
//            }
//        }
//    }
}
