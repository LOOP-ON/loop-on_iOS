//
//  RoutineCardView.swift
//  Loop_On
//
//  Created by 이경민 on 1/14/26.
//

import Foundation
import SwiftUI

struct RoutineCardView: View {
    let title: String
    let time: String
    let isCompleted: Bool // 완료 여부
    let onConfirm: () -> Void
    let onDelay: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))

                Text(time)
                    .font(.system(size: 13))
                    .foregroundStyle(Color("25-Text"))
            }

            Spacer()

            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(.primaryColorVarient65))
                    .font(.system(size: 24))
                    .frame(width: 56)
            } else {
                VStack(spacing: 8) {
                    actionButton("인증", action: onConfirm)
                    actionButton("미루기", action: onDelay)
                }
            }
        }
        .padding(16)
        .frame(minHeight: 98)
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
            title: "아침에 일어나 물 한 컵 마시기",
            time: "08:00 알림 예정",
            isCompleted: false,
            onConfirm: {},
            onDelay: {}
        )

        RoutineCardView(
            title: "정해진 시간에 침대에 눕기",
            time: "23:00 알림 예정",
            isCompleted: false,
            onConfirm: {},
            onDelay: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
