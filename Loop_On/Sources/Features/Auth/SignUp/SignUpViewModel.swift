//
//  File.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import Foundation
import SwiftUI
import UIKit

enum SignUpSheet: Identifiable {
    case agreement
    var id: Int { hashValue }
}

@MainActor
final class SignUpViewModel: ObservableObject {
    /// 비밀번호 - 회원가입 1단계에서만 사용
    @Published var password: String = ""
    @Published var passwordConfirm: String = ""
    /// 이름/닉네임/프로필 이미지는 ProfileView에서 관리
    
    // 현재 활성화된 시트 관리 변수
    @Published var activeSheet: SignUpSheet? = nil
    
    private var lastCheckedEmail: String = ""
    @Published var email: String = "" {
        didSet {
            let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)

            // 이메일이 바뀌면 이전 중복확인 결과 무효화
            if trimmed != lastCheckedEmail {
                emailCheckState = .idle
            }
        }
    }

    // 회원가입
    @Published var isShowingAgreementPopup: Bool = false
    private let networkManager = DefaultNetworkManager<AuthAPI>()

    @Published var isSignUpSuccess: Bool = false
    @Published var errorMessage: String?

    func requestSignUp() {
        // 화면에서 막더라도 혹시 모를 오동작을 대비해 1차 방어 로직 추가
        guard canGoNext else {
            errorMessage = "회원가입 정보를 다시 확인해주세요."
            return
        }
        
        // Xcode 프리뷰 또는 로컬 UI 테스트용 더미 처리. 서버 열리면 여기 지우기
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            // 네트워크 없이 바로 성공 처리
            self.isSignUpSuccess = true
            return
        }
        #endif

        // 필요한 데이터 생성
        let requestData = SignUpRequest(
            email: self.email,
            password: self.password,
            confirmPassword: self.passwordConfirm,
            // 이름/닉네임/생년월일은 이후 프로필 단계에서 입력하므로 현재는 nil로 전송
            name: nil,
            nickname: nil,
            birthDate: nil
        )
        
        // 네트워크 요청
        networkManager.request(
            target: .signUp(request: requestData),
            decodingType: EmptyResponse.self // 혹은 유저 정보를 담은 모델
        ) { [weak self] result in
            switch result {
            case .success:
                self?.isSignUpSuccess = true
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
        }
    }


    // 이메일 중복 체크
    enum EmailCheckState: Equatable {
        case idle
        case checking
        case available
        case duplicated
        case invalidFormat
    }
    @Published var emailCheckState: EmailCheckState = .idle
//    @Published var helperText: String = "Helper Text"

    // Agreements
    struct AgreementItem: Identifiable {
        let id = UUID()
        let title: String
        let isRequired: Bool
        let hasDetail: Bool
        var isOn: Bool
    }

    @Published var agreements: [AgreementItem] = [
        .init(title: "LOOP:ON 이용약관 동의", isRequired: true, hasDetail: true, isOn: false),
        .init(title: "개인정보 수집·이용 동의", isRequired: true, hasDetail: true, isOn: false),
        .init(title: "서비스 성격 고지 체크", isRequired: true, hasDetail: true, isOn: false),
        .init(title: "개인정보 수집·이용 동의", isRequired: false, hasDetail: true, isOn: false),
        .init(title: "개인정보 제 3자 제공 동의", isRequired: false, hasDetail: true, isOn: false),
        .init(title: "마케팅 정보 수신 동의", isRequired: false, hasDetail: true, isOn: false),
    ]

    var isAllRequiredAgreed: Bool {
        agreements.filter { $0.isRequired }.allSatisfy { $0.isOn }
    }
    
    var isPasswordValid: Bool {
        // (영문, 숫자 포함 8~16자) - 간단 예시
        let lenOK = (8...16).contains(password.count)
        let hasLetter = password.range(of: "[A-Za-z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        return lenOK && hasLetter && hasNumber
    }

    var isPasswordMatch: Bool {
        !passwordConfirm.isEmpty && password == passwordConfirm
    }
    
    var isPasswordMismatch: Bool {
        !password.isEmpty &&
        !passwordConfirm.isEmpty &&
        password != passwordConfirm
    }

    // Helper 영역에 표시할 메시지 (없으면 nil)
    var helperMessage: String? {
        switch emailCheckState {
        case .invalidFormat:
            return "이메일 형식이 올바르지 않습니다."
        case .duplicated:
            return "이미 가입된 이메일입니다."
        case .checking:
            return "중복 확인 중..."
        case .idle:
            let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                return "중복 확인을 진행해주세요."
            }
        default:
            break
        }

        if isPasswordMismatch {
            return "비밀번호가 일치하지 않습니다."
        }

        return nil
    }


    var helperTextColorName: String {
        // 에러 메시지면 빨간색
        switch emailCheckState {
        case .invalidFormat, .duplicated:
            return "errorRed" // 색상 에셋 이름이 없으면 아래에서 설명한 대로 변경
        default:
            break
        }
        return isPasswordMismatch ? "errorRed" : "45-Text"
    }


    var canGoNext: Bool {
        emailCheckState == .available && isPasswordValid && isPasswordMatch
    }

    func checkEmailDuplicate() async {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isValidEmail(trimmed) else {
            emailCheckState = .invalidFormat
            return
        }

        emailCheckState = .checking

        try? await Task.sleep(nanoseconds: 600_000_000)

        if trimmed.lowercased().contains("used") {
            emailCheckState = .duplicated
        } else {
            emailCheckState = .available
            lastCheckedEmail = trimmed
        }
    }


    private func isValidEmail(_ s: String) -> Bool {
        // 너무 엄격하지 않은 간단 패턴
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return s.range(of: pattern, options: .regularExpression) != nil
    }
}
