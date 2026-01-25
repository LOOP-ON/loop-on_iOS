//
//  ChallengeFriend.swift
//  Loop_On
//
//  Created by 이경민 on 1/22/26.
//

import Foundation

struct ChallengeFriend: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let isSelf: Bool
}

extension ChallengeFriend {
    static let sampleFriends: [ChallengeFriend] = [
        ChallengeFriend(name: "서리 (나)", subtitle: "LOOP:ON 디자이너 서리/최서정", isSelf: true),
        ChallengeFriend(name: "쥬디", subtitle: "LOOP:ON PM 쥬디/안채빈", isSelf: false),
        ChallengeFriend(name: "키미", subtitle: "LOOP:ON iOS 키미/이경민", isSelf: false),
        ChallengeFriend(name: "써니", subtitle: "LOOP:ON iOS 써니/김세은", isSelf: false),
        ChallengeFriend(name: "핀", subtitle: "LOOP:ON iOS 핀/문인성", isSelf: false),
        ChallengeFriend(name: "허니", subtitle: "LOOP:ON SpringBoot 허니/박창현", isSelf: false),
        ChallengeFriend(name: "엔찌", subtitle: "LOOP:ON SpringBoot 엔찌/장예은", isSelf: false),
        ChallengeFriend(name: "레미드", subtitle: "LOOP:ON SpringBoot 레미드/최승원", isSelf: false),
        ChallengeFriend(name: "루비", subtitle: "LOOP:ON 디자인 루비/홍길동", isSelf: false),
        ChallengeFriend(name: "미루", subtitle: "LOOP:ON 기획 미루/김하늘", isSelf: false),
        ChallengeFriend(name: "레오", subtitle: "LOOP:ON iOS 레오/정민수", isSelf: false),
        ChallengeFriend(name: "제이", subtitle: "LOOP:ON 백엔드 제이/윤지수", isSelf: false)
    ]
}
