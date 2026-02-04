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

    @Published var nickname: String = "서리"
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
        guard !category.isEmpty else {
            // TODO: GoalSelect에서 category 전달 누락 시 처리
            return
        }
        // Step2: 목표 입력 + category로 여정 목표 생성 API 호출
        isSaving = true
        errorMessage = nil
        print(category)
        return

        let request = JourneyGoalRequest(goal: trimmedGoal, category: category)

        networkManager.request(
            target: .createJourneyGoal(request: request),
            decodingType: ApiResponse<JourneyGoalResponse>.self
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isSaving = false

                switch result {
                case .success(let response):
                    if response.isSuccess {
                        self.journeyId = response.result?.journeyId
                    } else {
                        self.errorMessage = response.message
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}


