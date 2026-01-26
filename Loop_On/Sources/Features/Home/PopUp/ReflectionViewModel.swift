//
//  ReflectionViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 1/26/26.
//

import Foundation
import SwiftUI
import Combine
import Photos

class ReflectionViewModel: ObservableObject {
    @Published var reflectionText: String = ""
    @Published var selectedImages: [UIImage] = []
    @Published var isSaving: Bool = false
    @Published var isCompleted: Bool = false // 저장 완료 여부
    
    let loopId: Int
    let currentDay: Int
    
    init(loopId: Int, currentDay: Int) {
        self.loopId = loopId
        self.currentDay = currentDay
    }
    
    // MARK: - API 저장 로직 (Mock)
    func saveReflection(completion: @escaping (Bool) -> Void) {
        guard !reflectionText.isEmpty else { return }
        
        self.isSaving = true
        
        // 서버 전송 시뮬레이션
        let requestDTO = ReflectionRequestDTO(
            loopId: self.loopId,
            day: self.currentDay,
            content: self.reflectionText,
            imageCount: self.selectedImages.count
        )
        
        print("서버로 전송 시도: \(requestDTO)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isSaving = false
            self.isCompleted = true
            completion(true)
        }
    }
    
    var canSave: Bool {
        return !reflectionText.isEmpty && !isSaving
    }
}
