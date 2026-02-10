//
//  ChallengeFriendRequest.swift
//  Loop_On
//
//  Created by 이경민 on 1/22/26.
//

import Foundation

struct ChallengeFriendRequest: Identifiable {
    let id: Int
    let name: String
    let subtitle: String
    let imageURL: String?
}

extension ChallengeFriendRequest {
    static let sampleRequests: [ChallengeFriendRequest] = [
        ChallengeFriendRequest(id: 1, name: "세이", subtitle: "속삭벤치 PM 세이/소아연", imageURL: nil),
        ChallengeFriendRequest(id: 2, name: "로로", subtitle: "또랑 PM 로로/정제훈", imageURL: nil),
        ChallengeFriendRequest(id: 3, name: "샤오", subtitle: "부키부키 PM 샤오/장우영", imageURL: nil),
        ChallengeFriendRequest(id: 4, name: "리아", subtitle: "루프온 디자이너 리아/김지은", imageURL: nil),
        ChallengeFriendRequest(id: 5, name: "도하", subtitle: "루프온 기획 도하/박지후", imageURL: nil),
        ChallengeFriendRequest(id: 6, name: "로이", subtitle: "루프온 백엔드 로이/이승현", imageURL: nil),
        ChallengeFriendRequest(id: 7, name: "하린", subtitle: "루프온 iOS 하린/최민아", imageURL: nil),
        ChallengeFriendRequest(id: 8, name: "제트", subtitle: "루프온 안드로이드 제트/정소윤", imageURL: nil),
        ChallengeFriendRequest(id: 9, name: "루카", subtitle: "루프온 QA 루카/한지우", imageURL: nil),
        ChallengeFriendRequest(id: 10, name: "에린", subtitle: "루프온 운영 에린/신예린", imageURL: nil)
    ]
}
