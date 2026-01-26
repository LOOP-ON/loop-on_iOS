//
//  DelayReason.swift
//  Loop_On
//
//  Created by 이경민 on 1/15/26.
//

import Foundation

struct DelayReason: Identifiable, Codable, Hashable {
    let id: UUID
    let text: String
    
    init(id: UUID = UUID(), text: String) {
        self.id = id
        self.text = text
    }
    
    // "직접 입력" 옵션인지 확인하는 연산 프로퍼티
    var isCustomInput: Bool {
        return text == "직접 입력"
    }
}

// 초기 데이터 리스트
let delayReasonsData = [
    DelayReason(text: "시간이 부족해요."),
    DelayReason(text: "컨디션이 좋지 않아요."),
    DelayReason(text: "다른 할 일이 많아요."),
    DelayReason(text: "너무 귀찮아요."),
    DelayReason(text: "직접 입력")
]
