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

    // 네트워크
    private let networkManager = DefaultNetworkManager<AuthAPI>()

    @Published var errorMessage: String?


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
        let termId: Int
        let title: String
        let isRequired: Bool
        let hasDetail: Bool
        var isOn: Bool
    }

    @Published var agreements: [AgreementItem] = [
        // 서버 약관 ID(termId)는 백엔드에서 내려주는 값에 맞춰야 합니다.
        // 현재는 예시로 1~6을 매핑해두었고, 실제 ID가 다르면 여기만 수정하면 됩니다.
        .init(termId: 1, title: "LOOP:ON 이용약관 동의", isRequired: true, hasDetail: true, isOn: false),
        .init(termId: 2, title: "개인정보 수집·이용 동의", isRequired: true, hasDetail: true, isOn: false),
        .init(termId: 3, title: "서비스 성격 고지 체크", isRequired: true, hasDetail: true, isOn: false),
        .init(termId: 4, title: "개인정보 수집·이용 동의(선택)", isRequired: false, hasDetail: true, isOn: false),
        .init(termId: 5, title: "개인정보 제 3자 제공 동의(선택)", isRequired: false, hasDetail: true, isOn: false),
        .init(termId: 6, title: "마케팅 정보 수신 동의(선택)", isRequired: false, hasDetail: true, isOn: false),
    ]

    var isAllRequiredAgreed: Bool {
        agreements.filter { $0.isRequired }.allSatisfy { $0.isOn }
    }
    
    /// 서버로 전송할 약관 동의 ID 목록
    var selectedAgreedTermIds: [Int] {
        agreements
            .filter { $0.isOn }
            .map { $0.termId }
            .sorted()
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
        if let errorMessage = errorMessage {
                return errorMessage
        }
        
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
        emailCheckState == .available && isPasswordValid && isPasswordMatch && isAllRequiredAgreed
    }

    func checkEmailDuplicate() async {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 이메일 형식 검사
        guard isValidEmail(trimmed) else {
            emailCheckState = .invalidFormat
            return
        }

        // 이미 사용 가능으로 확인한 이메일과 같으면 성공 상태를 재사용
        if trimmed == lastCheckedEmail {
            emailCheckState = .available
            errorMessage = nil
            return
        }

        emailCheckState = .checking
        errorMessage = nil
        
        // API 호출 및 결과 파싱
        let result = await requestAsync(target: .checkEmail(email: trimmed), decodingType: EmailCheckResponse.self)
        
        switch result {
        case .success(let response):
            // 서버에서 준 isAvailable 값에 따라 상태 결정
            if response.isAvailable {
                emailCheckState = .available
                lastCheckedEmail = trimmed
                errorMessage = nil
            } else {
                // 중복된 경우 서버가 준 메시지 활용
                emailCheckState = .duplicated
                errorMessage = response.message
            }
            
        case .failure(let error):
            print("DEBUG - 이메일 중복 확인 실패: \(error)")
            emailCheckState = .idle
            // 서버 에러 메시지가 있다면 표시
            errorMessage = error.localizedDescription
        }
    }

    /// completion 기반 네트워크를 async로 감싸서 사용 (UI 코드 단순화)
    private func requestStatusCodeAsync(target: AuthAPI) async -> Result<Void, NetworkError> {
        await withCheckedContinuation { continuation in
            networkManager.requestStatusCode(target: target) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    private func requestAsync<T: Decodable>(target: AuthAPI, decodingType: T.Type) async -> Result<T, NetworkError> {
        await withCheckedContinuation { continuation in
            networkManager.request(target: target, decodingType: decodingType) { result in
                continuation.resume(returning: result)
            }
        }
    }


    private func isValidEmail(_ s: String) -> Bool {
        // 너무 엄격하지 않은 간단 패턴
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return s.range(of: pattern, options: .regularExpression) != nil
    }
}

struct EmailCheckResponse: Decodable {
    let isAvailable: Bool
    let message: String
}
