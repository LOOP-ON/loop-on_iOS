//
//  FindPasswordViewModel.swift
//  Loop_On
//
//  Created by Auto on 1/14/26.
//

import Foundation

@MainActor
final class FindPasswordViewModel: ObservableObject {
    private let passwordResetPurpose = "PASSWORD_RESET"

    // Email Verification Section
    @Published var email: String = "" {
        didSet {
            // 이메일이 변경되면 인증 상태 초기화
            if email != oldValue {
                resetVerificationState()
            }
        }
    }
    @Published var verificationCode: String = "" {
        didSet {
            // 인증 완료 후에는 텍스트 변경 방지
            if isVerificationCodeVerified && verificationCode != oldValue {
                verificationCode = oldValue
            }
        }
    }
    @Published var isVerificationRequested: Bool = false
    @Published var isVerificationCodeVerified: Bool = false
    @Published var isRequestingVerification: Bool = false
    @Published var isVerifyingCode: Bool = false
    
    // Success Messages
    @Published var verificationCodeSentMessage: String? // "인증번호가 이메일로 발송되었습니다."
    @Published var verificationSuccessMessage: String? // "인증되었습니다."
    @Published var passwordMatchMessage: String? // "비밀번호가 일치합니다."
    
    // Timer
    @Published var remainingTime: Int = 0 // 초 단위
    private var timerTask: Task<Void, Never>?
    
    // Password Section
    @Published var newPassword: String = "" {
        didSet {
            checkPasswordMatch()
        }
    }
    @Published var confirmPassword: String = "" {
        didSet {
            checkPasswordMatch()
        }
    }
    @Published var isPasswordResetComplete: Bool = false
    @Published var resetToken: String?
    
    // Error Messages
    @Published var emailErrorMessage: String?
    @Published var verificationErrorMessage: String?
    @Published var passwordErrorMessage: String?
    
    @Published var isLoading: Bool = false
    
    private let networkManager = DefaultNetworkManager<AuthAPI>()
    
    // 이메일 검증
    var isEmailValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return isValidEmail(trimmed)
    }
    
    // 인증 요청 버튼 활성화
    var canRequestVerification: Bool {
        isEmailValid && !isRequestingVerification
    }
    
    // 인증번호 확인 버튼 활성화
    var canVerifyCode: Bool {
        !verificationCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
        !isVerifyingCode &&
        isVerificationRequested
    }
    
    // 비밀번호 유효성 검증
    var isPasswordValid: Bool {
        let trimmed = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        // 영문, 숫자 포함 8~16자
        let pattern = #"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,16}$"#
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }
    
    // 비밀번호 일치 확인
    var isPasswordMatch: Bool {
        !newPassword.isEmpty && 
        !confirmPassword.isEmpty && 
        newPassword == confirmPassword
    }
    
    // 최종 제출 버튼 활성화
    var canSubmitPasswordReset: Bool {
        isVerificationCodeVerified && 
        !(resetToken?.isEmpty ?? true) &&
        isPasswordValid && 
        isPasswordMatch && 
        !isLoading
    }
    
    // 이메일 형식 검증
    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
    
    // 인증 상태 초기화
    private func resetVerificationState() {
        verificationCode = ""
        isVerificationRequested = false
        isVerificationCodeVerified = false
        resetToken = nil
        emailErrorMessage = nil
        verificationErrorMessage = nil
        verificationCodeSentMessage = nil
        verificationSuccessMessage = nil
        stopTimer()
    }
    
    // 타이머 시작 (3분 = 180초)
    private func startTimer() {
        stopTimer()
        remainingTime = 180 // 3분
        
        timerTask = Task {
            while remainingTime > 0 && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기
                if !Task.isCancelled {
                    remainingTime -= 1
                }
            }
            
            // 타이머 종료 시 인증번호 입력 필드 비활성화
            if remainingTime == 0 {
                isVerificationRequested = false
                verificationCodeSentMessage = nil
            }
        }
    }
    
    // 타이머 중지
    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
        remainingTime = 0
    }
    
    // 타이머 포맷 (MM:SS)
    var timerString: String {
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // 비밀번호 일치 확인 및 메시지 업데이트
    private func checkPasswordMatch() {
        guard isVerificationCodeVerified else { return }
        
        // 비밀번호가 비어있으면 메시지 초기화
        if newPassword.isEmpty && confirmPassword.isEmpty {
            passwordMatchMessage = nil
            passwordErrorMessage = nil
            return
        }
        
        // 비밀번호 형식 검증
        if !newPassword.isEmpty && !isPasswordValid {
            passwordMatchMessage = nil
            passwordErrorMessage = "비밀번호는 영문, 숫자 포함 8~16자여야 합니다."
            return
        }
        
        // 비밀번호 일치 확인
        if !newPassword.isEmpty && !confirmPassword.isEmpty {
            if newPassword == confirmPassword {
                passwordMatchMessage = "비밀번호가 일치합니다."
                passwordErrorMessage = nil
            } else {
                passwordMatchMessage = nil
                passwordErrorMessage = "비밀번호가 일치하지 않습니다."
            }
        } else if !newPassword.isEmpty && confirmPassword.isEmpty {
            // 새 비밀번호만 입력된 경우
            passwordMatchMessage = nil
            passwordErrorMessage = nil
        } else {
            // 재입력 비밀번호만 입력된 경우
            passwordMatchMessage = nil
            passwordErrorMessage = nil
        }
    }
    
    // 인증 요청
    func requestVerification() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isValidEmail(trimmedEmail) else {
            emailErrorMessage = "올바른 이메일 형식을 입력해주세요."
            verificationCodeSentMessage = nil
            return
        }
        
        isRequestingVerification = true
        emailErrorMessage = nil
        verificationCodeSentMessage = nil
        verificationErrorMessage = nil

        networkManager.requestStatusCode(
            target: .sendVerification(request: .init(email: trimmedEmail, purpose: passwordResetPurpose))
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isRequestingVerification = false
                switch result {
                case .success:
                    self.isVerificationRequested = true
                    self.verificationCodeSentMessage = "인증번호가 이메일로 발송되었습니다."
                    self.verificationCode = ""
                    self.verificationSuccessMessage = nil
                    self.isVerificationCodeVerified = false
                    self.resetToken = nil
                    self.startTimer()
                case .failure(let error):
                    self.emailErrorMessage = error.localizedDescription
                    self.verificationCodeSentMessage = nil
                }
            }
        }
    }
    
    // 인증번호 확인
    func verifyCode() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCode = verificationCode.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedCode.isEmpty else {
            verificationErrorMessage = "인증번호를 입력해주세요."
            return
        }
        guard isVerificationRequested else {
            verificationErrorMessage = "먼저 인증 요청을 진행해주세요."
            return
        }
        
        isVerifyingCode = true
        verificationErrorMessage = nil

        networkManager.request(
            target: .verifyVerification(
                request: .init(
                    email: trimmedEmail,
                    code: trimmedCode,
                    purpose: passwordResetPurpose
                )
            ),
            decodingType: String.self
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isVerifyingCode = false
                switch result {
                case .success(let token):
                    self.isVerificationCodeVerified = true
                    self.verificationSuccessMessage = "인증되었습니다."
                    self.verificationErrorMessage = nil
                    self.verificationCodeSentMessage = nil
                    self.resetToken = token
                    self.stopTimer()
                case .failure(let error):
                    self.isVerificationCodeVerified = false
                    self.verificationErrorMessage = error.localizedDescription
                    self.verificationSuccessMessage = nil
                    self.resetToken = nil
                }
            }
        }
    }
    
    // 비밀번호 재설정
    func resetPassword() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let resetToken, !resetToken.isEmpty else {
            passwordErrorMessage = "인증이 만료되었습니다. 인증을 다시 진행해주세요."
            return
        }

        guard isVerificationCodeVerified else {
            passwordErrorMessage = "이메일 인증을 완료해주세요."
            return
        }
        
        guard isPasswordValid else {
            passwordErrorMessage = "비밀번호는 영문, 숫자 포함 8~16자여야 합니다."
            return
        }
        
        guard isPasswordMatch else {
            passwordErrorMessage = "비밀번호가 일치하지 않습니다."
            return
        }
        
        isLoading = true
        passwordErrorMessage = nil

        networkManager.requestStatusCode(
            target: .resetPassword(
                request: .init(
                    email: trimmedEmail,
                    resetToken: resetToken,
                    newPassword: trimmedPassword
                )
            )
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isLoading = false
                switch result {
                case .success:
                    self.isPasswordResetComplete = true
                case .failure(let error):
                    self.passwordErrorMessage = error.localizedDescription
                }
            }
        }
    }
    
    deinit {
        // deinit은 동기 컨텍스트이므로 MainActor 메서드를 호출할 수 없음
        // Task를 직접 취소
        timerTask?.cancel()
    }
}
