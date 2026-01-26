//
//  JourneyReportViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 1/26/26.
//

import Foundation
import SwiftUI

class JourneyReportViewModel: ObservableObject {
    @Published var reportData: JourneyReport?
    @Published var isLoading: Bool = false
    
    // API 연동을 위한 데이터 로드 함수
    func fetchReport(loopId: Int) {
        self.isLoading = true
        
        // TODO: 실제 API 연동 (URLSession/Moya)
        // 현재는 더미 데이터를 생성
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.reportData = JourneyReport(
                title: "\(loopId)번째 여정 완료 리포트",
                goal: "건강한 생활 만들기",
                routines: ["루틴 이름 1", "루틴 이름 2", "루틴 이름 3"],
                achievementRate: 85,
                feedback: "3일 동안 전체 루프의 85%를 달성했어요!\n이제 스스로 루틴을 이어갈 수 있을 것 같아요."
            )
            self.isLoading = false
        }
    }
    
    func shareToChallenge() {
        print("챌린지에 공유하기 액션 실행")
    }
}
