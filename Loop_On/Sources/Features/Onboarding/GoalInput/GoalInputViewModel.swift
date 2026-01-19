//
//  GoalInputViewModel.swift
//  Loop_On
//
//  Created by 써니/김세은
//

import Foundation

@MainActor
final class GoalInputViewModel: ObservableObject {
    @Published var nickname: String = "서리"
    @Published var goalText: String = ""

    let placeholder: String = "이곳을 눌러 입력해주세요! (18자 이내)"
    let maxLength: Int = 18

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
}


