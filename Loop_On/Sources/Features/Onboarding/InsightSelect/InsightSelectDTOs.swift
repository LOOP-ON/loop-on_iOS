//
//  InsightSelectDTOs.swift
//  Loop_On
//
//  Created by 김세은 on 1/22/26.
//

import Foundation

struct InsightSelectRequest: Encodable {
    // API Request: 사용자 입력 목표
    let goalText: String
    // API Request: 선택 카테고리 (SKILL/ROUTINE/MENTAL)
    let selectedCategory: String
    // API Request: 선택 인사이트 배열 (문자열)
    let selectedInsights: [String]
}

struct InsightSelectResponse: Decodable {
    // API Response: 추후 명세 확정 시 필드 추가
}
