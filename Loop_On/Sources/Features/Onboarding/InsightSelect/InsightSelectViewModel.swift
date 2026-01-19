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
    // 더미 데이터 (추후 GoalSelect 결과에 따라 goalTitle 주입/연동)
    @Published var goalTitle: String = "건강한 생활 만들기"

    @Published var insights: [InsightItem] = [
        .init(title: "생활 리듬 바꾸기"),
        .init(title: "기상 후 1시간 이내 아침 습관 만들기"),
        .init(title: "준비물 없는 행동으로 시작하기"),
        .init(title: "체력이 가장 많이 남아있는 시간대로 루틴 설정하기"),
        .init(title: "산책/스트레칭 등 가벼운 활동하기")
    ]

    @Published var selected: Set<InsightItem> = []

    /// 스펙: 0개도 허용할 경우 항상 활성
    var canCreateLoop: Bool { true }

    func toggle(_ item: InsightItem) {
        if selected.contains(item) {
            selected.remove(item)
        } else {
            selected.insert(item)
        }
    }
}


