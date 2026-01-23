//
//  RoutineCardView.swift
//  Loop_On
//
//  Created by 이경민 on 1/14/26.
//

import Foundation
import SwiftUI

struct RoutineCardView: View {
    // 개별 속성 대신 도메인 모델을 주입받음
    let routine: RoutineModel
    let onConfirm: () -> Void
    let onDelay: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(routine.title) // 모델의 title 사용
                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))

                Text(routine.time) // 모델의 time 사용
                    .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                    .foregroundStyle(Color("25-Text"))
            }

            Spacer()

            // 서버에서 받아온 완료 상태(isCompleted)에 따라 UI 분기
            if routine.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(.primaryColorVarient65))
                    .font(.system(size: 24))
                    .frame(width: 56, height: 68)
            } else {
                VStack(spacing: 8) {
                    actionButton("인증", action: onConfirm)
                    actionButton("미루기", action: onDelay)
                }
            }
        }
        .padding(16)
        .frame(minHeight: 96)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }

    private func actionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(width: 56, height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.primaryColorVarient65))
                )
        }
    }
}


#Preview {
    VStack(spacing: 12) {
        RoutineCardView(
            routine: RoutineModel(id: 1, title: "물 한 컵 마시기", time: "08:00", isCompleted: false),
            onConfirm: {},
            onDelay: {}
        )

        RoutineCardView(
            routine: RoutineModel(id: 2, title: "침대에 눕기", time: "23:00", isCompleted: true),
            onConfirm: {},
            onDelay: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
