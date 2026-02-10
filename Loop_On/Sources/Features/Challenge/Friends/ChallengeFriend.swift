//
//  ChallengeFriend.swift
//  Loop_On
//
//  Created by 이경민 on 1/22/26.
//

import Foundation

struct ChallengeFriend: Identifiable {
    let id: Int
    let name: String
    let subtitle: String
    let isSelf: Bool
    let imageURL: String?
    let status: String?
}

extension ChallengeFriend {
    static let sampleFriends: [ChallengeFriend] = [
        ChallengeFriend(id: 1, name: "서리 (나)", subtitle: "LOOP:ON 디자이너 서리/최서정", isSelf: true, imageURL: nil, status: nil),
        ChallengeFriend(id: 2, name: "쥬디", subtitle: "LOOP:ON PM 쥬디/안채빈", isSelf: false, imageURL: nil, status: nil),
        ChallengeFriend(id: 3, name: "키미", subtitle: "LOOP:ON iOS 키미/이경민", isSelf: false, imageURL: nil, status: nil),
        ChallengeFriend(id: 4, name: "써니", subtitle: "LOOP:ON iOS 써니/김세은", isSelf: false, imageURL: nil, status: nil),
        ChallengeFriend(id: 5, name: "핀", subtitle: "LOOP:ON iOS 핀/문인성", isSelf: false, imageURL: nil, status: nil),
        ChallengeFriend(id: 6, name: "허니", subtitle: "LOOP:ON SpringBoot 허니/박창현", isSelf: false, imageURL: nil, status: nil),
        ChallengeFriend(id: 7, name: "엔찌", subtitle: "LOOP:ON SpringBoot 엔찌/장예은", isSelf: false, imageURL: nil, status: nil),
        ChallengeFriend(id: 8, name: "레미드", subtitle: "LOOP:ON SpringBoot 레미드/최승원", isSelf: false, imageURL: nil, status: nil),
        ChallengeFriend(id: 9, name: "루비", subtitle: "LOOP:ON 디자인 루비/홍길동", isSelf: false, imageURL: nil, status: nil),
        ChallengeFriend(id: 10, name: "미루", subtitle: "LOOP:ON 기획 미루/김하늘", isSelf: false, imageURL: nil, status: nil),
        ChallengeFriend(id: 11, name: "레오", subtitle: "LOOP:ON iOS 레오/정민수", isSelf: false, imageURL: nil, status: nil),
        ChallengeFriend(id: 12, name: "제이", subtitle: "LOOP:ON 백엔드 제이/윤지수", isSelf: false, imageURL: nil, status: nil)
    ]
}
