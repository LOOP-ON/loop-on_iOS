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

    func submitGoal(completion: @escaping (Bool) -> Void) {
        let trimmedGoal = goalText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedGoal.isEmpty else {
            completion(false)
            return
        }

        isSaving = true
        let request = JourneyGoalRequest(goal: trimmedGoal, category: category)

        networkManager.request(
            target: .createJourneyGoal(request: request),
            decodingType: JourneyGoalResponse.self
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case .success(let response):
                    self.journeyId = response.journeyId
                    completion(true) // 성공 알림
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isSaving = false
                    completion(false)
                }
            }
        }
    }
    
    @Published var recommendedInsights: [String] = [] // API로 받은 인사이트 저장용

    // 9번 api의 journeys/goals 랑 12번 api 2개 호출해야함
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
                    if let firstJourneyId = response.loops.first?.journeyId {
                        self.journeyId = firstJourneyId
                    }
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
        self.isSaving = true // 로딩 시작
        
        // 여정 목표 생성 API 호출 (/api/journeys/goals)
        submitGoal { success in
            if success {
                // 추천 루프 생성 API 호출 (/api/goals/loops)
                // 이 메서드 내부에서 self.recommendedInsights에 결과가 저장
                self.generateRecommendedLoops { recommendedSuccess in
                    self.isSaving = false // 모든 작업 완료 후 로딩 해제
                    completion(recommendedSuccess)
                }
            } else {
                self.isSaving = false
                completion(false)
            }
        }
    }
}


