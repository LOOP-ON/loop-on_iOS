//
//  UserViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 12/31/25.
//

import Foundation

struct UserViewModel {
    let id: String
    let name: String
    let profileImageURL: String?
    let bio: String
        
    // 도메인 로직: 프로필이 완성되었는지 확인
    var isProfileComplete: Bool {
        !name.isEmpty && !bio.isEmpty
    }
        
    // 도메인 로직: 표시용 이름 생성
    var displayName: String {
        name.isEmpty ? "익명 사용자" : name
    }
}
