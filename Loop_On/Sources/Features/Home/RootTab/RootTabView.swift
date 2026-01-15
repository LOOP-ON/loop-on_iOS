//
//  RootTabView.swift
//  Loop_On
//
//  Created by 이경민 on 1/15/26.
//

import Foundation
import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: TabItem = .home

    var body: some View {
        // 배경색은 화면 전체(노치 포함)를 채움.
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            // 실제 레이아웃은 여기서부터 시작 (상단 노치를 자동으로 피함)
            VStack(spacing: 0) {
                // 상단 컨텐츠 영역
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView()
                    case .history:
                        HistoryView()
                    case .challenge:
                        Text("챌린지 화면")
                    case .profile:
                        Text("프로필 화면")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // 하단 탭바 영역
                HomeBottomTabView(selectedTab: $selectedTab)
            }
        }
        // 하단 탭바의 흰색 배경만 기기 바닥까지 늘어지게 설정.
        .ignoresSafeArea(.container, edges: .bottom)
    }
}
