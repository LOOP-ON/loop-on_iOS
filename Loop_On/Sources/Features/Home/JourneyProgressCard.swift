//
//  JourneyProgressCard.swift
//  Loop_On
//
//  Created by 이경민 on 1/14/26.
//

import Foundation
import SwiftUI

struct JourneyProgressCardView: View {
    let completed: Int
    let total: Int

    var progress: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("오늘의 여정 완주율")
                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                .foregroundStyle(Color.white)

            Text("\(completed)/\(total)")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.white)

            JourneyProgressBarView(progress: progress)


            Text(completed == 0 ? "아직 완료된 루틴이 없어요" : "잘 진행 중이에요!")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.primaryColorVarient65))
        )
    }
}

struct JourneyProgressBarView: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {

                // 배경 (흰색)
                Capsule()
                    .fill(Color.white.opacity(0.9))

                // 채워진 영역
                Capsule()
                    .fill(Color(.primaryColor55))
                    .frame(
                        width: geometry.size.width * max(0, min(progress, 1))
                    )
            }
        }
        .frame(height: 10)
    }
}


#Preview {
    VStack(spacing: 16) {
        JourneyProgressCardView(
            completed: 0,
            total: 3
        )

        JourneyProgressCardView(
            completed: 2,
            total: 3
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
