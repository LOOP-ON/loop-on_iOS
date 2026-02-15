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
    let routines: [JourneyRecordRoutineDTO]
    let day1Rate: Double
    let day2Rate: Double
    let day3Rate: Double
    let achievementRate: Double
    let feedback: String
}
