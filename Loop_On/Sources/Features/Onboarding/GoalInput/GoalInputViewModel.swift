//
//  GoalInputViewModel.swift
//  Loop_On
//
//  Created by 써니/김세은
//

import Foundation

@MainActor
final class GoalInputViewModel: ObservableObject {
    private let networkManager = DefaultNetworkManager<OnboardingAPI>()

    @Published var nickname: String = ""
    @Published var goalText: String = ""
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?
    @Published var journeyId: Int?

    let category: String
    let placeholder: String = "이곳을 눌러 입력해주세요! (18자 이내)"
    let maxLength: Int = 18

    init(category: String) {
        self.category = category
    }

    var canProceed: Bool {
        !goalText.isEmpty
    }
    
    func updateNickname(_ name: String) {
        self.nickname = name
    }

    func updateGoalText(_ newValue: String) {
        if newValue.count > maxLength {
            goalText = String(newValue.prefix(maxLength))
        } else {
            goalText = newValue
        }
    }

    func submitGoal() {
        let trimmedGoal = goalText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedGoal.isEmpty else { return }
        guard !category.isEmpty else { return }

        isSaving = true
        errorMessage = nil

        let request = JourneyGoalRequest(goal: trimmedGoal, category: category)

        networkManager.request(
            target: .createJourneyGoal(request: request),
            decodingType: JourneyGoalResponse.self
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isSaving = false

                switch result {
                case .success(let response):
                    self.journeyId = response.journeyId
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    @Published var recommendedInsights: [String] = [] // API로 받은 인사이트 저장용

    /// POST /api/goals/loops 호출 후 성공 시 completion(true), 실패 시 completion(false) 호출.
    /// completion은 항상 Main 스레드에서 호출되도록 보장합니다.
    func generateRecommendedLoops(completion: @escaping (Bool) -> Void) {
        let trimmedGoal = goalText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedGoal.isEmpty else {
            errorMessage = "목표를 입력해주세요."
            completion(false)
            return
        }

        isSaving = true
        errorMessage = nil

        let request = LoopRecommendationRequest(goal: trimmedGoal, loopCount: 5)

        networkManager.request(
            target: .generateLoops(request: request),
            decodingType: LoopRecommendationResponse.self
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isSaving = false
                switch result {
                case .success(let response):
                    self.recommendedInsights = response.loops.map { $0.goal }
                    completion(true)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
}


