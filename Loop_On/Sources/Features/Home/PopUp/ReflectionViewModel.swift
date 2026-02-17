//
//  ReflectionViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 1/26/26.
//

import Foundation
import SwiftUI
import Combine

class ReflectionViewModel: ObservableObject {
    @Published var reflectionText: String = ""
    @Published var isSaving: Bool = false
    @Published var isCompleted: Bool = false // 저장 완료 여부
    @Published var errorMessage: String?
    
    let journeyId: Int
    let loopId: Int
    let currentDay: Int
    let goalTitle: String
    private let networkManager = DefaultNetworkManager<HomeAPI>()
    
    init(journeyId: Int, loopId: Int, currentDay: Int, goalTitle: String) {
        self.journeyId = journeyId
        self.loopId = loopId
        self.currentDay = currentDay
        self.goalTitle = goalTitle
    }
    
    // MARK: - API 저장 로직
    func saveReflection(completion: @escaping (Bool) -> Void) {
        guard canSave else { return }
        guard journeyId > 0 else {
            errorMessage = "여정 정보를 찾지 못했어요."
            completion(false)
            return
        }
        
        self.isSaving = true
        self.errorMessage = nil

        let request = RoutineRecordRequest(
            content: reflectionText.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        networkManager.request(
            target: .createRoutineRecord(journeyId: journeyId, request: request),
            decodingType: RoutineRecordData.self
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
        return hasText && !isSaving
    }
}
