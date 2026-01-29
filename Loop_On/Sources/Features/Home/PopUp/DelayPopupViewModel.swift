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
    func submitDelay(routineIndex: Int, completion: @escaping (Bool) -> Void) {
        guard canSubmit else { return }
        
        isSubmitting = true
        
        // TODO: 실제 API 연동 시 URLSession이나 Moya 등을 여기서 호출
        print("API 요청 전송 중... [루틴: \(routineIndex), 사유: \(finalReason)]")
        
        // 가상의 네트워크 지연 처리 (2초 후 성공 가정)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isSubmitting = false
            print("API 요청 성공")
            completion(true)
        }
    }
}
