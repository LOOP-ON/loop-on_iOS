//
//  ProfileModel.swift
//  Loop_On
//
//  Created by Auto on 1/14/26.
//

import Foundation

struct ProfileModel {
    let id: String?
    let name: String
    let nickname: String
    let birthday: String
    let profileImageURL: String?
    
    // 도메인 로직: 프로필이 완성되었는지 확인
    var isProfileComplete: Bool {
        !name.isEmpty && !nickname.isEmpty && isValidBirthday
    }
    
    // 도메인 로직: 생년월일 형식 검증 (YYYYMMDD)
    var isValidBirthday: Bool {
        guard birthday.count == 8 else { return false }
        guard birthday.allSatisfy({ $0.isNumber }) else { return false }
        
        let year = Int(birthday.prefix(4)) ?? 0
        let month = Int(birthday.dropFirst(4).prefix(2)) ?? 0
        let day = Int(birthday.suffix(2)) ?? 0
        
        return year >= 1900 && year <= 2100 &&
               month >= 1 && month <= 12 &&
               day >= 1 && day <= 31
    }
    
    // 도메인 로직: 닉네임 길이 검증
    var isValidNickname: Bool {
        !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // 도메인 로직: 표시용 생년월일 포맷 (YYYY.MM.DD)
    var formattedBirthday: String {
        guard birthday.count == 8 else { return birthday }
        let year = birthday.prefix(4)
        let month = birthday.dropFirst(4).prefix(2)
        let day = birthday.suffix(2)
        return "\(year).\(month).\(day)"
    }
}

extension Character {
    var isKorean: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.value >= 0xAC00 && scalar.value <= 0xD7A3
    }
}
