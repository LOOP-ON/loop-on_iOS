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
    let isConfirmDisabled: Bool // 전날 미완료 루틴 처리 모드일 때 true
    let onConfirm: () -> Void
    let onDelay: () -> Void
    let onViewDelay: () -> Void

    var body: some View {
        HStack {
            if routine.isDelayed {
                Image("next_plan")
                    .font(.system(size: 24))
            } else if routine.isCompleted {
                Image("check_circle")
                    .font(.system(size: 24))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(routine.title) // 모델의 title 사용
                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .foregroundStyle(routine.isCompleted ? Color.gray : Color.black)

                Text(routine.time) // 모델의 time 사용
                    .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                    .foregroundStyle(Color("25-Text"))
            }
            .padding(.leading, 6)

            Spacer()

            // 서버에서 받아온 완료 상태(isCompleted)에 따라 UI 분기
            if routine.isDelayed {
                actionButton("미루기 보기", width: 78,height: 30, action: onViewDelay)
            } else if routine.isCompleted {
                Text("완료")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color(.primaryColorVarient65))
                    .frame(width: 56, height: 68)
            } else {
                VStack(spacing: 8) {
                    actionButton("인증", isEnabled: !isConfirmDisabled, action: onConfirm)
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

    private func actionButton(_ title: String,
                                  width: CGFloat = 56,
                                  height: CGFloat = 30,
                                  isEnabled: Bool = true,
                                  action: @escaping () -> Void) -> some View {
            Button(action: action) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.white)
                    // 지정된 너비와 높이 적용
                    .frame(width: width, height: height)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isEnabled ? Color(.primaryColorVarient65) : Color.gray.opacity(0.4))
                    )
            }
        }
}


#Preview {
    VStack(spacing: 12) {
        // 상황 1: 일반적인 활성화 상태
        RoutineCardView(
            routine: RoutineModel(id: 1, routineProgressId: 11, title: "물 한 컵 마시기", time: "08:00", isCompleted: false, isDelayed: false, delayReason: ""),
            isConfirmDisabled: false, //
            onConfirm: {},
            onDelay: {},
            onViewDelay: {}
        )

        // 상황 2: 전날 미완료 루틴이 있어 '인증'이 비활성화된 상태
        RoutineCardView(
            routine: RoutineModel(id: 2, routineProgressId: 12, title: "침대에 눕기", time: "23:00", isCompleted: false, isDelayed: false, delayReason: ""),
            isConfirmDisabled: true, //
            onConfirm: {},
            onDelay: {},
            onViewDelay: {}
        )
        
        // 상황 3: 이미 미루기를 완료한 상태
        RoutineCardView(
            routine: RoutineModel(id: 3, routineProgressId: 13, title: "미룬 루틴 보기", time: "00:00 알림 완료", isCompleted: false, isDelayed: true, delayReason: "컨디션이 좋지 않아요"),
            isConfirmDisabled: false,
            onConfirm: {},
            onDelay: {},
            onViewDelay: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
