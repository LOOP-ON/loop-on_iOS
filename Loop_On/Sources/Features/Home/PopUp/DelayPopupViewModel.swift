//
//  DelayPopupViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 1/26/26.
//

import Foundation
import SwiftUI

class DelayPopupViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedReason: DelayReason? = nil
    @Published var customReason: String = ""
    @Published var isSubmitting: Bool = false // API 통신 중 로딩 상태 관리
    
    let reasons: [DelayReason] = delayReasonsData
    private let networkManager = DefaultNetworkManager<HomeAPI>()
    
    // MARK: - Logic
    
    var canSubmit: Bool {
        guard let selected = selectedReason else { return false }
        if selected.isCustomInput {
            return !customReason.trimmingCharacters(in: .whitespaces).isEmpty
        }
        return true
    }
    
    var finalReason: String {
        if let selected = selectedReason {
            return selected.isCustomInput ? customReason : selected.text
        }
        return ""
    }
    
    // MARK: - API Integration (준비 단계)
    func submitDelay(journeyId: Int, progressId: Int, completion: @escaping (Bool) -> Void) {
        guard canSubmit else { return }
        guard journeyId > 0, progressId > 0 else {
            completion(false)
            return
        }
        
        isSubmitting = true
        
        // 프리뷰 환경인지 확인 (충돌 방지의 핵심)
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            self.isSubmitting = false
            completion(true)
            return
        }
        #endif
        
        let request = RoutinePostponeRequest(
            progressIds: [progressId],
            reason: finalReason
        )

        networkManager.requestStatusCode(
            target: .postponeRoutine(journeyId: journeyId, request: request)
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isSubmitting = false
                switch result {
                case .success:
                    completion(true)
                case .failure(let error):
                    print("루틴 미루기 실패: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
    
    func setupInitialReason(_ reasonText: String) {
        // 기본 리스트에서 일치하는 텍스트가 있는지 확인
        if let matchedReason = reasons.first(where: { $0.text == reasonText }) {
            self.selectedReason = matchedReason
            self.customReason = ""
        }
        // 일치하는 게 없다면 "직접 입력"으로 간주
        else {
            self.selectedReason = reasons.first(where: { $0.isCustomInput })
            self.customReason = reasonText
        }
    }
}
