//
//  FindPasswordViewModel.swift
//  Loop_On
//
//  Created by Auto on 1/14/26.
//

import Foundation

@MainActor
final class FindPasswordViewModel: ObservableObject {
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
        guard isEmailValid else {
            emailErrorMessage = "올바른 이메일 형식을 입력해주세요."
            verificationCodeSentMessage = nil
            return
        }
        
        isRequestingVerification = true
        emailErrorMessage = nil
        verificationCodeSentMessage = nil
        verificationErrorMessage = nil
        
        // TODO: 실제 API 호출로 변경
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5초 대기
            
            // 더미 로직: 이메일이 "loopon@soongsil.ac.kr"이 아니면 에러 표시
            let trimmedEmail = self.email.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedEmail != "loopon@soongsil.ac.kr" {
                self.isRequestingVerification = false
                self.emailErrorMessage = "가입되지 않은 이메일입니다."
                self.verificationCodeSentMessage = nil
                return
            }
            
            // 성공: 인증번호 발송
            self.isRequestingVerification = false
            self.isVerificationRequested = true
            self.verificationCodeSentMessage = "인증번호가 이메일로 발송되었습니다."
            self.verificationCode = "" // 인증번호 필드 초기화
            self.verificationSuccessMessage = nil
            self.isVerificationCodeVerified = false
            self.startTimer() // 타이머 시작
        }
    }
    
    // 인증번호 확인
    func verifyCode() {
        guard !verificationCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            verificationErrorMessage = "인증번호를 입력해주세요."
            return
        }
        
        isVerifyingCode = true
        verificationErrorMessage = nil
        
        // TODO: 실제 API 호출로 변경
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기
            
            // 더미 로직: 인증번호가 "0000"이면 성공, 아니면 실패
            let trimmedCode = self.verificationCode.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedCode == "0000" {
                // 성공
                self.isVerifyingCode = false
                self.isVerificationCodeVerified = true
                self.verificationSuccessMessage = "인증되었습니다."
                self.verificationErrorMessage = nil
                self.verificationCodeSentMessage = nil
                self.stopTimer() // 타이머 중지
            } else {
                // 실패
                self.isVerifyingCode = false
                self.isVerificationCodeVerified = false
                self.verificationErrorMessage = "잘못된 인증번호입니다."
                self.verificationSuccessMessage = nil
            }
        }
    }
    
    // 비밀번호 재설정
    func resetPassword() {
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
        
        // TODO: 실제 API 호출로 변경
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5초 대기
            
            // 더미 로직: 항상 성공
            self.isLoading = false
            self.isPasswordResetComplete = true
        }
    }
    
    deinit {
        // deinit은 동기 컨텍스트이므로 MainActor 메서드를 호출할 수 없음
        // Task를 직접 취소
        timerTask?.cancel()
    }
}
