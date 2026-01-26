//
//  JourneyReport.swift
//  Loop_On
//
//  Created by 이경민 on 1/26/26.
//

import Foundation

struct JourneyReport: Codable {
    let title: String
    let goal: String
    let routines: [String]
    let achievementRate: Int
    let feedback: String
}
