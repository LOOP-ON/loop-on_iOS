//
//  GoalSelectViewModel.swift
//  Loop_On
//
//  Created by 써니/김세은
//

import Foundation

enum GoalType: String, CaseIterable {
    case capability = "역량 강화"
    case routine = "생활 루틴"
    case innerManagement = "내면 관리"
    
    var emoji: String {
        switch self {
        case .capability:
            return "💪"
        case .routine:
            return "🌿"
        case .innerManagement:
            return "💌"
        }
    }
    
    var title: String {
        switch self {
        case .capability:
            return "역량 강화"
        case .routine:
            return "생활 루틴"
        case .innerManagement:
            return "내면 관리"
        }
    }
}

@MainActor
final class GoalSelectViewModel: ObservableObject {
    @Published var selectedGoal: GoalType?
    @Published var nickname: String = "서리" // TODO: 실제 사용자 닉네임으로 변경
    
    var canProceed: Bool {
        selectedGoal != nil
    }
    
    func selectGoal(_ goal: GoalType) {
        selectedGoal = goal
    }
    
    func proceedToNext() {
        guard let goal = selectedGoal else { return }
        // TODO: goal_type으로 저장하고 다음 화면으로 이동
        print("Selected goal: \(goal.rawValue)")
    }
}

