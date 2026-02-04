//
//  ProfileEditViewModel.swift
//  Loop_On
//
//  Created by Auto on 1/15/26.
//

import Foundation
import SwiftUI

@MainActor
final class ProfileEditViewModel: ObservableObject {
    @Published var nickname: String = ""
    @Published var oneLineIntro: String = ""
    @Published var statusMessage: String = ""
    @Published var isPublic: Bool = true
    
    @Published var isCheckingDuplication: Bool = false
    @Published var duplicationCheckResult: DuplicationCheckResult = .idle
    
    // 원래 닉네임 저장 (변경 여부 확인용)
    private let originalNickname: String
    
    enum DuplicationCheckResult {
        case idle
        case available
        case duplicated
        case checking
    }
    
    // 닉네임이 변경되었는지 확인
    var isNicknameChanged: Bool {
        nickname.trimmingCharacters(in: .whitespacesAndNewlines) != originalNickname.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    init(initialUser: UserModel) {
        // 초기값 설정
        self.nickname = initialUser.name
        self.originalNickname = initialUser.name
        // bio를 한 줄 소개와 상태 메시지로 분리
        let bioLines = initialUser.bio.components(separatedBy: "\n")
        if bioLines.count > 0 {
            self.oneLineIntro = bioLines[0]
        }
        if bioLines.count > 1 {
            self.statusMessage = bioLines[1]
        }
    }
    
    func checkNicknameDuplication() {
        isCheckingDuplication = true
        duplicationCheckResult = .checking
        
        // 테스트: "인성" 입력 시 무조건 통과
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isCheckingDuplication = false
            // "인성" 입력 시 무조건 통과
            if trimmedNickname == "인성" {
                self.duplicationCheckResult = .available
            } else {
                // TODO: API 호출로 중복 확인
                // 임시로 항상 사용 가능으로 설정
                self.duplicationCheckResult = .available
            }
        }
    }
    
    func saveProfile() {
        // TODO: API 호출로 프로필 저장
        print("프로필 저장: 닉네임=\(nickname), 한줄소개=\(oneLineIntro), 상태메시지=\(statusMessage), 공개=\(isPublic)")
    }
}
