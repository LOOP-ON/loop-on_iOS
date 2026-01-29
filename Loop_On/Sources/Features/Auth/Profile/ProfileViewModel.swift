//
//  ProfileViewModel.swift
//  Loop_On
//
//  Created by Auto on 1/14/26.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var nickname: String = ""
    @Published var birthday: String = ""
    @Published var profileImageURL: String?
    
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isProfileSaved: Bool = false
    
    private let networkManager = DefaultNetworkManager<ProfileAPI>()
    
    // 입력 검증 상태
    enum ValidationState {
        case idle
        case valid
        case invalid(String)
    }
    
    @Published var nameValidation: ValidationState = .idle
    @Published var nicknameValidation: ValidationState = .idle
    @Published var birthdayValidation: ValidationState = .idle
    
    // 닉네임 중복 확인 상태
    enum NicknameCheckState: Equatable {
        case idle
        case checking
        case available
        case duplicated
        case invalidFormat
    }
    @Published var nicknameCheckState: NicknameCheckState = .idle
    private var lastCheckedNickname: String = ""
    
    // 이름 검증
    var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // 닉네임 검증
    var isNicknameValid: Bool {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        
        let koreanCount = trimmed.filter { $0.isKorean }.count
        let otherCount = trimmed.count - koreanCount
        
        if koreanCount > 0 {
            return trimmed.count <= 7
        } else {
            return trimmed.count <= 10
        }
    }
    
    // 생년월일 검증
    var isBirthdayValid: Bool {
        let trimmed = birthday.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count == 8 else { return false }
        guard trimmed.allSatisfy({ $0.isNumber }) else { return false }
        
        let year = Int(trimmed.prefix(4)) ?? 0
        let month = Int(trimmed.dropFirst(4).prefix(2)) ?? 0
        let day = Int(trimmed.suffix(2)) ?? 0
        
        return year >= 1900 && year <= 2100 &&
               month >= 1 && month <= 12 &&
               day >= 1 && day <= 31
    }
    
    // 모든 필드가 유효한지 확인
    var canSaveProfile: Bool {
        // 디자인 변경: 닉네임만 필수 입력/검증 대상으로 사용
        isNicknameValid &&
        nicknameCheckState == .available
    }
    
    // 닉네임 도움말 텍스트
    var nicknameHelperText: String? {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        if !isNicknameValid {
            let koreanCount = trimmed.filter { $0.isKorean }.count
            if koreanCount > 0 {
                return "한글은 7자 이내로 입력해주세요."
            } else {
                return "영문/숫자는 10자 이내로 입력해주세요."
            }
        }
        return nil
    }
    
    // 생년월일 도움말 텍스트
    var birthdayHelperText: String? {
        let trimmed = birthday.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        if !isBirthdayValid {
            if trimmed.count != 8 {
                return "생년월일은 8자리로 입력해주세요."
            } else if !trimmed.allSatisfy({ $0.isNumber }) {
                return "숫자만 입력해주세요."
            } else {
                return "올바른 날짜 형식이 아닙니다."
            }
        }
        return nil
    }
    
    // 프로필 저장
    func saveProfile() {
        guard canSaveProfile else {
            validateAllFields()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let profileDTO = ProfileDTO(
            userId: nil,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            nickname: nickname.trimmingCharacters(in: .whitespacesAndNewlines),
            birthday: birthday.trimmingCharacters(in: .whitespacesAndNewlines),
            profileImage: profileImageURL
        )
        
        networkManager.request(
            target: .createProfile(profile: profileDTO),
            decodingType: ApiResponse<ProfileDTO>.self
        ) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let response):
                if response.isSuccess {
                    self.isProfileSaved = true
                } else {
                    self.errorMessage = response.message
                }
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // 모든 필드 검증
    private func validateAllFields() {
        // 현재는 닉네임만 실질적인 검증 대상으로 사용
        nicknameValidation = isNicknameValid ? .valid : .invalid(nicknameHelperText ?? "닉네임을 입력해주세요.")
    }
    
    // 이름 실시간 검증
    func validateName() {
        nameValidation = isNameValid ? .valid : .invalid("이름을 입력해주세요.")
    }
    
    // 닉네임 실시간 검증
    func validateNickname() {
        nicknameValidation = isNicknameValid ? .valid : .invalid(nicknameHelperText ?? "닉네임을 입력해주세요.")
    }
    
    // 생년월일 실시간 검증
    func validateBirthday() {
        birthdayValidation = isBirthdayValid ? .valid : .invalid(birthdayHelperText ?? "생년월일을 입력해주세요.")
    }
    
    // 닉네임 중복 확인
    func checkNicknameDuplicate() async {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 형식 검증
        guard isNicknameValid else {
            nicknameCheckState = .invalidFormat
            return
        }
        
        // 이전에 확인한 닉네임과 같으면 스킵
        guard trimmed != lastCheckedNickname else {
            return
        }
        
        nicknameCheckState = .checking
        
        // TODO: 실제 API 호출로 변경
        try? await Task.sleep(nanoseconds: 600_000_000)
        
        // 더미 로직: "used"가 포함되면 중복
        if trimmed.lowercased().contains("used") {
            nicknameCheckState = .duplicated
        } else {
            nicknameCheckState = .available
            lastCheckedNickname = trimmed
        }
    }
}
