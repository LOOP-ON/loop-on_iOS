//
//  JourneyGoalDTOs.swift
//  Loop_On
//
//  Created by 김세은 on 1/22/26.
//

import Foundation

struct JourneyGoalRequest: Encodable {
    let goal: String
    let category: String
}

struct JourneyGoalResponse: Decodable {
    let journeyId: Int
}
