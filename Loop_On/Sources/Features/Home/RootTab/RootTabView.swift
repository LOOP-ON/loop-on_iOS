//
//  RootTabView.swift
//  Loop_On
//
//  Created by 이경민 on 1/15/26.
//

import Foundation
import SwiftUI

// 슬라이드 방식으로 부드럽게 넘어가는 스타일
struct RootTabView: View {
    @State private var selectedTab: TabItem = .home
    @EnvironmentObject var homeViewModel: HomeViewModel

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 상단 컨텐츠 영역: TabView를 사용하여 슬라이드 애니메이션 구현
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tag(TabItem.home)

                    HistoryView()
                        .tag(TabItem.history)

                    ChallengeView()
                        .tag(TabItem.challenge)

                    Text("프로필 화면")
                        .tag(TabItem.profile)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // 하단 탭바 영역
                HomeBottomTabView(selectedTab: $selectedTab)
            }
            // 최상위 ZStack에서 팝업을 띄워 노치와 탭바를 모두 덮어준다
            if homeViewModel.activeFullSheet == .reflection {
                if let info = homeViewModel.journeyInfo {
                    ReflectionPopupView(
                        viewModel: ReflectionViewModel(loopId: info.loopId, currentDay: info.currentDay),
                        isPresented: Binding(
                            get: { homeViewModel.activeFullSheet == .reflection },
                            set: { if !$0 { homeViewModel.activeFullSheet = nil } }
                        )
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    .zIndex(999)
                }
            }
        }
        // 하단 탭바의 흰색 배경만 기기 바닥까지 늘어지게 설정
        .ignoresSafeArea(.container, edges: .bottom)
        // 탭이 바뀔 때 전체적으로 부드러운 애니메이션 부여
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
    }
}

// Fade in-out 방식으로 전환
//struct RootTabView: View {
//    @State private var selectedTab: TabItem = .home
//
//    var body: some View {
//        ZStack {
//            Color(.systemGroupedBackground)
//                .ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                // 상단 컨텐츠 영역
//                ZStack {
//                    switch selectedTab {
//                    case .home:
//                        HomeView()
//                            .transition(.opacity) // 페이드 효과 지정
//                    case .history:
//                        HistoryView()
//                            .transition(.opacity)
//                    case .challenge:
//                        Text("챌린지 화면")
//                            .transition(.opacity)
//                    case .profile:
//                        Text("프로필 화면")
//                            .transition(.opacity)
//                    }
//                }
//                .id(selectedTab)    // transition이 작동하려면 id가 바뀌거나 뷰가 제거/추가되어야 하므로 id를 부여
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//
//                // 하단 탭바 영역
//                HomeBottomTabView(selectedTab: $selectedTab)
//            }
//        }
//        .ignoresSafeArea(.container, edges: .bottom)
//        .animation(.easeInOut(duration: 0.2), value: selectedTab)   // selectedTab 값이 바뀔 때 애니메이션 실행
//    }
//}
