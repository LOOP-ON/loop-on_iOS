//
//  ProfileViewModel.swift
//  Loop_On
//
//  Created by Auto on 1/14/26.
//

import Foundation
import _PhotosUI_SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var nickname: String = ""
    @Published var birthday: String = ""
    @Published var profileImageURL: String?
    
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isProfileSaved: Bool = false
    
    private let networkManager = DefaultNetworkManager<AuthAPI>()
    private var flowStore: SignUpFlowStore?
    
    @Published var selectedImageData: Data? // 선택된 이미지
    
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
        return !trimmed.isEmpty
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
        isNicknameValid && nicknameCheckState == .available
    }
    
    // 닉네임 도움말 텍스트
    var nicknameHelperText: String? {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        if !isNicknameValid {
            return "닉네임을 입력해주세요."
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
//    func completeSignUp() {
//        guard canSaveProfile else {
//            validateAllFields()
//            return
//        }
//        guard let flowStore else {
//            errorMessage = "회원가입 정보를 불러올 수 없습니다. 이전 화면부터 다시 진행해주세요."
//            return
//        }
//        
//        isLoading = true
//        errorMessage = nil
//        
//        // 2단계 입력값을 스토어에 반영
//        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
//        flowStore.setProfile(nickname: trimmedNickname, profileImageUrl: profileImageURL)
//        
//        // 최종 회원가입 요청 바디 생성
//        let request = SignUpRequest(
//            email: flowStore.email,
//            password: flowStore.password,
//            confirmPassword: flowStore.confirmPassword,
//            nickname: flowStore.nickname,
//            profileImageUrl: flowStore.profileImageUrl,
//            agreedTermIds: flowStore.agreedTermIds
//        )
//        
//        // 응답 포맷이 ApiResponse를 쓰지 않더라도 동작하도록 상태코드 기반으로 처리
//        networkManager.requestStatusCode(target: .signUp(request: request)) { [weak self] result in
//            guard let self else { return }
//            self.isLoading = false
//            
//            switch result {
//            case .success:
//                self.isProfileSaved = true
//            case .failure(let error):
//                self.errorMessage = error.localizedDescription
//            }
//        }
//    }
    
    @Published var imageItem: PhotosPickerItem? {
        didSet {
            Task {
                // 사용자가 사진을 고르면 데이터를 로드
                if let data = try? await imageItem?.loadTransferable(type: Data.self) {
                    self.selectedImageData = data // 서버로 보낼 실제 데이터
                }
            }
        }
    }
    
    @Published var imageSelection: PhotosPickerItem? {
        didSet {
            if let imageSelection {
                loadTransferable(from: imageSelection)
            }
        }
    }
    
    // PhotosPickerItem에서 Data를 추출하는 함수
    private func loadTransferable(from imageSelection: PhotosPickerItem) {
        Task {
            do {
                // 이미지를 Data 타입으로 로드
                if let data = try await imageSelection.loadTransferable(type: Data.self) {
                    self.selectedImageData = data
                }
            } catch {
                self.errorMessage = "이미지를 불러오는 데 실패했습니다."
            }
        }
    }

    
    func completeSignUp() {
        guard canSaveProfile else {
            validateAllFields()
            return
        }

        isLoading = true
        errorMessage = nil

        if let imageData = selectedImageData {
            // 사진이 있는 경우: 이미지 업로드 후 회원가입 진행
            uploadImageAndSignUp(imageData: imageData)
        } else {
            // 사진이 없는 경우: 바로 회원가입 진행
            executeFinalSignUp()
        }
    }
    
    // 이미지 업로드 전용 함수
    private func uploadImageAndSignUp(imageData: Data) {
    networkManager.request(
        target: .uploadProfileImage(data: imageData, fileName: "profile.jpg", mimeType: "image/jpeg"),
        decodingType: String.self
    ) { [weak self] result in
            guard let self else { return }
            
        switch result {
        case .success(let uploadedUrl):
            // 서버가 준 이미지 URL을 저장
            print("DEBUG: 이미지 업로드 성공 - URL: \(uploadedUrl)")
            self.profileImageURL = uploadedUrl
                
            // 성공한 URL을 가지고 회원가입 API를 호출
            self.executeFinalSignUp()
                
        case .failure(let error):
            self.isLoading = false
            self.errorMessage = "이미지 업로드 실패: \(error.localizedDescription)"
        }
    }
}
    
    // 최종 회원가입 API 호출
    private func executeFinalSignUp() {
        guard let flowStore else { return }
            
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        flowStore.setProfile(nickname: trimmedNickname, profileImageUrl: profileImageURL)
            
        let request = SignUpRequest(
            email: flowStore.email,
            password: flowStore.password,
            confirmPassword: flowStore.confirmPassword,
            nickname: flowStore.nickname,
            profileImageUrl: flowStore.profileImageUrl,
            agreedTermIds: flowStore.agreedTermIds
        )
        
        networkManager.requestStatusCode(target: .signUp(request: request)) { [weak self] result in
            guard let self else { return }

            Task { @MainActor in
                switch result {
                case .success:
                    // 회원가입 응답의 data가 숫자(userId)인 경우가 있어 상태코드 성공만 확인하고,
                    // 이후 동일 계정으로 로그인해 토큰을 발급받는다.
                    self.loginAfterSignUp(email: flowStore.email, password: flowStore.password)

                case .failure(let error):
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    print("DEBUG: 회원가입 API 실패 - \(error)")
                }
            }
        }
    }

    private func loginAfterSignUp(email: String, password: String) {
        networkManager.request(
            target: .login(email: email, password: password),
            decodingType: LoginData.self
        ) { [weak self] result in
            guard let self else { return }

            Task { @MainActor in
                self.isLoading = false
                switch result {
                case .success(let loginData):
                    KeychainService.shared.saveToken(loginData.accessToken)
                    self.isProfileSaved = true
                    print("DEBUG: 회원가입 성공 후 자동 로그인 및 토큰 저장 완료")

                case .failure(let error):
                    self.errorMessage = "회원가입은 완료됐지만 자동 로그인에 실패했어요. 로그인 화면에서 다시 로그인해주세요."
                    print("DEBUG: 회원가입 후 자동 로그인 실패 - \(error)")
                }
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
        
        guard isNicknameValid else {
            nicknameCheckState = .invalidFormat
            errorMessage = "닉네임을 입력해주세요."
            return
        }
        
        // 이전에 성공적으로 확인한 닉네임과 같다면 성공 상태를 재사용
        if trimmed == lastCheckedNickname {
            nicknameCheckState = .available
            errorMessage = nil
            return
        }
        
        nicknameCheckState = .checking
        errorMessage = nil
        let currentRequestNickname = trimmed

        let result = await requestAsync(
            target: .checkNickname(nickname: trimmed),
            decodingType: NicknameCheckResponseDTO.self
        )
        guard nickname.trimmingCharacters(in: .whitespacesAndNewlines) == currentRequestNickname else { return }

        switch result {
        case .success(let response):
            if response.isAvailable {
                nicknameCheckState = .available
                lastCheckedNickname = currentRequestNickname
                errorMessage = nil
            } else {
                nicknameCheckState = .duplicated
                errorMessage = response.message.isEmpty ? "이미 사용 중인 닉네임입니다." : response.message
            }

        case .failure(let error):
            if case let .serverError(statusCode, message) = error, statusCode == 409 {
                nicknameCheckState = .duplicated
                errorMessage = message.isEmpty ? "이미 사용 중인 닉네임입니다." : message
            } else {
                nicknameCheckState = .idle
                errorMessage = "중복 확인 중 오류가 발생했습니다."
            }
            print("DEBUG: 닉네임 중복 체크 실패: \(error)")
        }
    }
    
    /// SignUpView 에서 입력한 값을 프로필 단계에서 사용하기 위해 바인딩
    func bindFlowStore(_ store: SignUpFlowStore) {
        self.flowStore = store
    }
    
    private func requestAsync<T: Decodable>(
        target: AuthAPI,
        decodingType: T.Type
    ) async -> Result<T, NetworkError> {
        await withCheckedContinuation { continuation in
            networkManager.request(target: target, decodingType: decodingType) { result in
                continuation.resume(returning: result)
            }
        }
    }
}
