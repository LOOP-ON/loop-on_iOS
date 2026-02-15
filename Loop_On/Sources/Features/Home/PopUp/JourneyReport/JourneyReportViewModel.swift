//
//  JourneyReportViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 1/26/26.
//

import Foundation
import SwiftUI

class JourneyReportViewModel: ObservableObject {
    @Published var reportData: PopupJourneyReport?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private let networkManager = DefaultNetworkManager<HomeAPI>()
    
    // API 연동을 위한 데이터 로드 함수
    func fetchReport(journeyId: Int) {
        guard journeyId > 0 else {
            errorMessage = "여정 정보를 찾지 못했어요."
            return
        }
        self.isLoading = true
        self.errorMessage = nil

        networkManager.request(
            target: .fetchJourneyRecord(journeyId: journeyId),
            decodingType: JourneyRecordData.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                switch result {
                case .success(let data):
                    let totalPercent = data.totalRate <= 1.0 ? Int(data.totalRate * 100) : Int(data.totalRate)
                    self.reportData = PopupJourneyReport(
                        title: "\(data.journeyId)번째 여정 완료 리포트",
                        goal: data.goal,
                        routines: data.routines,
                        day1Rate: data.day1Rate,
                        day2Rate: data.day2Rate,
                        day3Rate: data.day3Rate,
                        achievementRate: data.totalRate,
                        feedback: "3일 동안 전체 루프의 \(totalPercent)%를 달성했어요!\n다음 여정도 이어가볼까요?"
                    )
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func shareToChallenge() {
        print("챌린지에 공유하기 액션 실행")
    }
}
