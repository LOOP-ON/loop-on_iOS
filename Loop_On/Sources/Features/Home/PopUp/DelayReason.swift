//
//  DelayReason.swift
//  Loop_On
//
//  Created by 이경민 on 1/15/26.
//

import Foundation

struct DelayReason: Identifiable {
    let id = UUID()
    let text: String
}

let delayReasons = [
    DelayReason(text: "시간이 부족해요."),
    DelayReason(text: "컨디션이 좋지 않아요."),
    DelayReason(text: "다른 할 일이 많아요."),
    DelayReason(text: "너무 귀찮아요."),
    DelayReason(text: "직접 입력")
]
