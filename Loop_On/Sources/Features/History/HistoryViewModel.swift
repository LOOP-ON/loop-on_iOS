//
//  HistoryViewModel.swift
//  Loop_On
//
//  Created by Auto on 1/15/26.
//

import Foundation
import SwiftUI

@MainActor
class HistoryViewModel: ObservableObject {
    // 날짜별 루틴 달성 개수 (예시 데이터)
    // 실제로는 API에서 가져와야 함
    @Published var routineCompletionCount: [Date: Int] = [:]
    
    init() {
        // 예시 데이터 - 실제로는 API에서 가져와야 함
        setupExampleData()
    }
    
    /// 특정 날짜의 루틴 달성 개수 반환
    func getCompletionCount(for date: Date) -> Int {
        let calendar = Calendar.current
        let dateKey = calendar.startOfDay(for: date)
        return routineCompletionCount[dateKey] ?? 0
    }
    
    /// 예시 데이터 설정 (개발용)
    private func setupExampleData() {
        let calendar = Calendar.current
        let today = Date()
        
        // 예시: 최근 며칠간의 달성 데이터
        for i in 0..<31 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dateKey = calendar.startOfDay(for: date)
                // 랜덤하게 0~3개의 달성 개수 설정
                routineCompletionCount[dateKey] = Int.random(in: 0...3)
            }
        }
    }
}
