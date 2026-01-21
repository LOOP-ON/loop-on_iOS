//
//  CommonPopupView.swift
//  Loop_On
//
//  Created by 이경민 on 1/21/26.
//

import Foundation
import SwiftUI

struct CommonPopupView: View {
    let title: String
    var message: String? = nil
    let leftButtonText: String
    let rightButtonText: String
    let leftAction: () -> Void
    let rightAction: () -> Void

    var body: some View {
        ZStack {
            // 배경 흐리게
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                    
                    if let message = message {
                        Text(message)
                            .font(.system(size: 16))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.vertical, 30)

                Divider()

                HStack(spacing: 0) {
                    // 왼쪽 버튼
                    Button(action: leftAction) {
                        Text(leftButtonText)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color(.primaryColorVarient65))
                            .frame(maxWidth: .infinity, maxHeight: 50)
                    }

                    Divider().frame(height: 50)

                    // 오른쪽 버튼
                    Button(action: rightAction) {
                        Text(rightButtonText)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color(.primaryColorVarient65))
                            .frame(maxWidth: .infinity, maxHeight: 50)
                    }
                }
            }
            .frame(minHeight: 100)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .padding(.horizontal, 62)
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()
        
        VStack(spacing: 50) {
            
            // 여정 완료 팝업 (FinishJourney)
            CommonPopupView(
                title: "3일 여정이 끝났어요!",
                message: "이번 루프를 돌아보러 갈까요?",
                leftButtonText: "다음 루프 시작하기",
                rightButtonText: "리포트 보기",
                leftAction: { print("다음 루프 클릭") },
                rightAction: { print("리포트 보기 클릭") }
            )
            
            // 여정 지속 확인 팝업 (ContinueJourney)
            CommonPopupView(
                title: "여정을 이어갈까요?",
                leftButtonText: "이어가기",
                rightButtonText: "새롭게 시작하기",
                leftAction: { print("이어가기 클릭") },
                rightAction: { print("새로 시작 클릭") }
            )
        }
    }
}
