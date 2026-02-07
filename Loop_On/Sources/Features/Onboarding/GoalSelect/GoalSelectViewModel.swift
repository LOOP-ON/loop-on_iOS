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

    var apiValue: String {
        switch self {
        case .capability:
            return "SKILL"
        case .routine:
            return "ROUTINE"
        case .innerManagement:
            return "MENTAL"
        }
    }
}

@MainActor
final class GoalSelectViewModel: ObservableObject {
    @Published var selectedGoal: GoalType?
    @Published var nickname: String = ""
    
    func updateNickname(_ name: String) {
        self.nickname = name
    }
    
    var canProceed: Bool {
        selectedGoal != nil
    }

    var selectedCategory: String? {
        selectedGoal?.apiValue
    }
    
    func selectGoal(_ goal: GoalType) {
        selectedGoal = goal
    }
    
    func proceedToNext() -> String? {
        // Step1에서 선택한 카테고리(API 값)를 반환
        selectedCategory
    }
}

