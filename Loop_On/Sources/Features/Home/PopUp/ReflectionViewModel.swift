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
import UIKit

class ReflectionViewModel: ObservableObject {
    @Published var reflectionText: String = ""
    @Published var selectedImages: [UIImage] = []
    @Published var isSaving: Bool = false
    @Published var isCompleted: Bool = false // 저장 완료 여부
    @Published var errorMessage: String?
    
    let loopId: Int
    let currentDay: Int
    let goalTitle: String
    let progressId: Int
    private let networkManager = DefaultNetworkManager<HomeAPI>()
    
    init(loopId: Int, currentDay: Int, goalTitle: String, progressId: Int) {
        self.loopId = loopId
        self.currentDay = currentDay
        self.goalTitle = goalTitle
        self.progressId = progressId
    }
    
    // MARK: - API 저장 로직
    func saveReflection(completion: @escaping (Bool) -> Void) {
        guard canSave else { return }
        guard progressId > 0 else {
            errorMessage = "여정 기록 대상 루틴을 찾지 못했어요."
            completion(false)
            return
        }
        
        self.isSaving = true
        self.errorMessage = nil
        let uploadImage = selectedImages.first ?? makeFallbackImage(from: reflectionText)
        guard let imageData = uploadImage.jpegData(compressionQuality: 0.85) else {
            self.isSaving = false
            self.errorMessage = "이미지 처리에 실패했어요."
            completion(false)
            return
        }
        
        let fileName = "reflection_\(progressId)_\(Int(Date().timeIntervalSince1970)).jpg"
        networkManager.requestStatusCode(
            target: .certifyRoutine(
                progressId: progressId,
                imageData: imageData,
                fileName: fileName,
                mimeType: "image/jpeg"
            )
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isSaving = false
                switch result {
                case .success:
                    self.isCompleted = true
                    completion(true)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
    
    var canSave: Bool {
        let hasText = !reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasImage = !selectedImages.isEmpty
        return (hasText || hasImage) && !isSaving
    }

    private func makeFallbackImage(from text: String) -> UIImage {
        let size = CGSize(width: 1080, height: 1080)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            paragraphStyle.lineBreakMode = .byWordWrapping

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 34, weight: .regular),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
            let safeText = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "오늘의 여정 기록" : text
            let textRect = CGRect(x: 40, y: 40, width: size.width - 80, height: size.height - 80)
            safeText.draw(in: textRect, withAttributes: attrs)
        }
    }
}
