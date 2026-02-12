//
//  RoutineCreateDTO.swift
//  Loop_On
//
//  Created by 이경민 on 2/8/26.
//

import Foundation

// RoutineCreateRequest: /api/routines 요청
struct RoutineCreateRequest: Encodable {
    let goal: String
    let category: String
    let selectedLoop: String // 선택한 인사이트
    let routines: [RoutineContentRequest]
}

// RoutineCreateResponse: /api/routines 응답
struct RoutineCreateResponse: Decodable {
    let data: JourneyIdData
    struct JourneyIdData: Decodable {
        let journeyId: Int
    }
}

//struct RoutineCreateRequest: Encodable {
//    let journeyId: Int
//    let routines: [RoutineContentRequest]
//}

struct RoutineContentRequest: Encodable {
    let content: String
    let time: String // "HH:mm" 형식 문자열
}

//struct RoutineCreateResponse: Decodable {
//    let result: String
//    let code: String
//    let message: String
//    let data: RoutineCreateData
//}

struct RoutineCreateData: Decodable {
    let journeyId: Int
    let routines: [RoutineDetail]
}

struct RoutineDetail: Decodable {
    let routineId: Int
    let content: String
    let notificationTime: String
}
