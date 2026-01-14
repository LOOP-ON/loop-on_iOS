//
//  HomeView.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import Foundation
import SwiftUI

struct HomeView: View {

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                HomeHeaderView()
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                journeyTitleView
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                JourneyProgressCardView(
                    completed: 0,
                    total: 3
                )
                .padding(.horizontal, 20)
                .padding(.top, 12)

                routineSectionView
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                recordButton
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 16)

                Spacer()
            }
        }
        .safeAreaInset(edge: .bottom) {
            HomeBottomTabView()
        }
    }
}

// MARK: - Subviews
private extension HomeView {

    var journeyTitleView: some View {
        HStack{
            VStack(alignment: .leading) {
                Text("첫 번째 여정")
                    .font(.system(size: 22, weight: .bold))
                
                Text("1일차 여정 진행 중")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(.primaryColorVarient65))
            }
            Spacer()
        }
    }

    var routineSectionView: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("목표 건강한 생활 만들기")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(.primaryColorVarient65))

            VStack(spacing: 8) {
                RoutineCardView(
                    title: "아침에 일어나 물 한 컵 마시기",
                    time: "08:00 알림 예정",
                    onConfirm: {},
                    onDelay: {}
                )

                RoutineCardView(
                    title: "낮 시간에 몸 움직이기",
                    time: "13:00 알림 예정",
                    onConfirm: {},
                    onDelay: {}
                )

                RoutineCardView(
                    title: "정해진 시간에 침대에 눕기",
                    time: "23:00 알림 예정",
                    onConfirm: {},
                    onDelay: {}
                )
            }
        }
    }

    var recordButton: some View {
        Button(action: {}) {
            Text("여정 기록하기")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.primaryColorVarient65))
                )
        }
    }
}


#Preview {
    HomeView()
}
