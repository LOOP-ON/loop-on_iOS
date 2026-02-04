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

    init(goalText: String, selectedCategory: String) {
        self.goalText = goalText
        self.selectedCategory = selectedCategory
        if !goalText.isEmpty {
            self.goalTitle = goalText
        }
    }

    /// 스펙: 0개도 허용할 경우 항상 활성
    var canCreateLoop: Bool { true }

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

    func createLoop() {
        // Step3: 인사이트 선택 결과를 다음 플로우로 전달
        // TODO: 선택 인사이트 배열 저장 후 루프 생성 로딩 화면으로 이동
        // API Request 구성
        let request = InsightSelectRequest(
            goalText: goalText,
            selectedCategory: selectedCategory,
            selectedInsights: selectedTitles
        )

        // API Call: POST /api/coach/insights (경로 확정 필요)
        isCreatingLoop = true
        errorMessage = nil

        networkManager.request(
            target: .createLoop(request: request),
            decodingType: ApiResponse<InsightSelectResponse>.self
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isCreatingLoop = false

                switch result {
                case .success(let response):
                    if !response.isSuccess {
                        self.errorMessage = response.message
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}


