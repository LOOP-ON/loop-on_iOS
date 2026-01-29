//
//  JourneyReport.swift
//  Loop_On
//
//  Created by 이경민 on 1/26/26.
//

import Foundation

// 홈 팝업 전용 리포트 모델 (History와 구분)
struct PopupJourneyReport: Codable {
    let title: String
    let goal: String
    let routines: [String]
    let achievementRate: Int
    let feedback: String
}
