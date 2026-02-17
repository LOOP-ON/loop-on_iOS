//
//  GoalInputViewModel.swift
//  Loop_On
//
//  Created by 써니/김세은
//

import Foundation
import Moya

@MainActor
final class GoalInputViewModel: ObservableObject {
    private let networkManager = DefaultNetworkManager<OnboardingAPI>()

    @Published var nickname: String = ""
    @Published var goalText: String = ""
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?
    @Published var journeyId: Int?
    @Published var recommendedInsights: [String] = []

    let category: String
    let placeholder: String = "이곳을 눌러 입력해주세요! (18자 이내)"
    let maxLength: Int = 18

    init(category: String) {
        self.category = category
    }

    var canProceed: Bool { !goalText.isEmpty }
    func updateNickname(_ name: String) { self.nickname = name }
    func updateGoalText(_ newValue: String) {
        goalText = newValue.count > maxLength ? String(newValue.prefix(maxLength)) : newValue
    }
    
    // MARK: - 통합된 API 호출 (9번/12번 통합)
    func fetchGoalRecommendations(completion: @escaping (Bool) -> Void) {
        let trimmedGoal = goalText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedGoal.isEmpty else {
            self.errorMessage = "목표를 입력해 주세요."
            completion(false)
            return
        }
        self.isSaving = true
        self.errorMessage = nil
            
        let request = JourneyGoalRequest(goal: trimmedGoal, category: category)

        networkManager.request(
            target: .createJourneyGoal(request: request), // /api/journeys/goals
            decodingType: GoalRecommendationData.self
        ) { [weak self] result in
            guard let self = self else { return }
            _Concurrency.Task { @MainActor in
                self.isSaving = false
                switch result {
                case .success(let response):
                    self.recommendedInsights = response.recommendations
                    completion(true)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
    
    // /api/journeys/goals 응답은 recommendations를 반환
    func submitGoal(completion: @escaping (Bool) -> Void) {
        let trimmedGoal = goalText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedGoal.isEmpty else {
            self.errorMessage = "목표를 입력해 주세요."
            completion(false)
            return
        }
        isSaving = true
        let request = JourneyGoalRequest(goal: trimmedGoal, category: category)

        networkManager.request(
            target: .createJourneyGoal(request: request),
            decodingType: GoalRecommendationData.self
        ) { [weak self] result in
            guard let self = self else { return }
            _Concurrency.Task { @MainActor in
                self.isSaving = false
                switch result {
                case .success(let response):
                    self.recommendedInsights = response.recommendations
                    completion(true)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
    
    // 12번 API - 입력한 목표를 기반으로 AI가 인사이트 5개 생성해준거 받아오는 api
    func generateRecommendedLoops(completion: @escaping (Bool) -> Void) {
        let trimmedGoal = goalText.trimmingCharacters(in: .whitespacesAndNewlines)
        isSaving = true
        let request = LoopRecommendationRequest(goal: trimmedGoal, loopCount: 5)

        networkManager.request(
            target: .generateLoops(request: request),
            decodingType: LoopRecommendationResponse.self
        ) { [weak self] result in
            guard let self = self else { return }
            _Concurrency.Task { @MainActor in
                self.isSaving = false
                switch result {
                case .success(let response):
                    if let firstId = response.loops.first?.journeyId { self.journeyId = firstId }
                    self.recommendedInsights = response.loops.map { $0.goal }
                    completion(true)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }

    func proceedToNextStep(completion: @escaping (Bool) -> Void) {
        self.isSaving = true
        submitGoal { success in
            if success {
                self.generateRecommendedLoops { recommendedSuccess in
                    self.isSaving = false
                    completion(recommendedSuccess)
                }
            } else {
                self.isSaving = false
                completion(false)
            }
        }
    }
}
