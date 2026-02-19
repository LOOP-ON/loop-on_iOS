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
    private let profileImageURL: String? // 프로필 이미지 URL (변경 불가하므로 기존 값 유지)
    
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
    
    private let authNetworkManager = DefaultNetworkManager<AuthAPI>()
    private let profileNetworkManager = DefaultNetworkManager<ProfileAPI>()
    
    init(initialUser: UserModel) {
        // 초기값 설정
        self.nickname = initialUser.name
        self.originalNickname = initialUser.name
        self.profileImageURL = initialUser.profileImageURL
        
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
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedNickname.isEmpty else {
            duplicationCheckResult = .idle
            return
        }
        
        isCheckingDuplication = true
        duplicationCheckResult = .checking
        
        authNetworkManager.requestStatusCode(target: .checkNickname(nickname: trimmedNickname)) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isCheckingDuplication = false
                
                switch result {
                case .success:
                    self.duplicationCheckResult = .available
                case .failure(let error):
                    if case let .serverError(statusCode, _) = error, statusCode == 409 {
                        self.duplicationCheckResult = .duplicated
                    } else {
                        self.duplicationCheckResult = .idle
                    }
                }
            }
        }
    }
    
    func saveProfile(completion: @escaping (Bool) -> Void) {
        // API 요청 DTO 생성
        let dto = ProfileUpdateRequestDTO(
            nickname: nickname,
            bio: oneLineIntro, // 한 줄 소개 -> bio
            statusMessage: statusMessage,
            profileImageUrl: profileImageURL ?? "", // 없으면 빈 문자열
            visibility: isPublic ? "PUBLIC" : "PRIVATE"
        )
        
        print("프로필 저장 요청: \(dto)")
        
        // 응답 타입은 UserMeResponseDTO와 유사하지만, 여기선 성공/실패 여부가 중요하므로
        // UserMeData(SessionStore에 정의된 것) 혹은 임의의 구조체 사용
        // 여기서는 편의상 내부 구조체 정의 없이, String 등으로 받거나 CommonResponseDTOs 활용
        // UserMeData가 있으므로 그것을 활용 (SessionStore.swift에 public으로 정의됨)
        profileNetworkManager.request(
            target: .updateUserProfile(request: dto),
            decodingType: UserMeData.self 
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    print("✅ 프로필 수정 성공: \(data.nickname)")
                    // 성공 시 별도 알림이나 처리가 필요하다면 여기서 수행
                    completion(true)
                case .failure(let error):
                    print("❌ 프로필 수정 실패: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
}
