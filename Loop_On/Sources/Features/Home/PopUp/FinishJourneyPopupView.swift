//
//  FinishJourneyPopupView.swift
//  Loop_On
//
//  Created by 이경민 on 1/20/26.
//

import Foundation
import SwiftUI

struct FinishJourneyPopupView: View {
    @Binding var isPresented: Bool
    var onNextLoop: () -> Void
    var onShowReport: () -> Void

    var body: some View {
        ZStack {
            // 배경 흐리게
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }

            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("3일 여정이 끝났어요!")
                        .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                    Text("이번 루프를 돌아보러 갈까요?")
                        .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                }
                .padding(.vertical, 30)

                Divider()

                HStack(spacing: 0) {
                    Button(action: onNextLoop) {
                        Text("다음 루프 시작하기")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color(.primaryColorVarient65))
                            .frame(maxWidth: .infinity, maxHeight: 50)
                    }

                    Divider()
                        .frame(height: 50)

                    Button(action: onShowReport) {
                        Text("리포트 보기")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color(.primaryColorVarient65))
                            .frame(maxWidth: .infinity, maxHeight: 50)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .frame(width: 290)
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()
        
        FinishJourneyPopupView(
            isPresented: .constant(true),
            onNextLoop: {
                print("다음 루프 시작하기 클릭")
            },
            onShowReport: {
                print("리포트 보기 클릭")
            }
        )
    }
}
