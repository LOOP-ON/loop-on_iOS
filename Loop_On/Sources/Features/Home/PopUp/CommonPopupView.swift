//
//  CommonPopupView.swift
//  Loop_On
//
//  Created by 이경민 on 1/21/26.
//

import Foundation
import SwiftUI

struct CommonPopupView: View {
    @Binding var isPresented: Bool
    let title: String
    var message: String? = nil
    let leftButtonText: String
    var rightButtonText: String? = nil
    let leftAction: () -> Void
    var rightAction: (() -> Void)? = nil
    var onClose: (() -> Void)? = nil

    var body: some View {
        ZStack {
            // 배경 흐리게
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    isPresented = false
                    onClose?()
                }

            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text(title)
                        .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                    
                    if let message = message {
                        Text(message)
                            .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.vertical, 30)

                Divider()

                if let rightButtonText, let rightAction {
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
                } else {
                    Button(action: leftAction) {
                        Text(leftButtonText)
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
            .contentShape(Rectangle())
            .onTapGesture { }
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()
        
        VStack(spacing: 50) {
            
            // 여정 완료 팝업 (FinishJourney)
            CommonPopupView(
                isPresented: .constant(true),
                title: "3일 여정이 끝났어요!",
                message: "이번 루프를 돌아보러 갈까요?",
                leftButtonText: "다음 루프 시작하기",
                rightButtonText: "리포트 보기",
                leftAction: { print("다음 루프 클릭") },
                rightAction: { print("리포트 보기 클릭") }
            )
            
            // 여정 지속 확인 팝업 (ContinueJourney)
            CommonPopupView(
                isPresented: .constant(true),
                title: "여정을 이어갈까요?",
                leftButtonText: "이어가기",
                rightButtonText: "새롭게 시작하기",
                leftAction: { print("이어가기 클릭") },
                rightAction: { print("새로 시작 클릭") }
            )
        }
    }
}
