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
    /// 타인 프로필 오버레이: 설정 시 이전 화면 위에 타인뷰를 올리고, 그 위에 탭바가 항상 보이게 함
    @State private var overlayUserId: Int? = nil
    @EnvironmentObject var homeViewModel: HomeViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            // 1) 탭 컨텐츠 (이전 화면)
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(TabItem.home)

                HistoryView()
                    .tag(TabItem.history)

                ChallengeView(onOpenOtherProfile: { overlayUserId = $0 })
                    .tag(TabItem.challenge)

                PersonalProfileView()
                    .tag(TabItem.profile)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 2) 타인뷰 오버레이 (이전 화면 위에 올림)
            if overlayUserId != nil {
                PersonalProfileView(isOwnProfile: false, onClose: { overlayUserId = nil })
                    .transition(.opacity)
                    .zIndex(1)
            }

            // 3) 하단 탭바를 맨 위에 유지 (타인뷰 위에도 항상 표시)
            VStack {
                Spacer()
                HomeBottomTabView(selectedTab: $selectedTab)
            }
            .zIndex(2)
            .onChange(of: selectedTab) { oldValue, newValue in
                // 타인뷰 오버레이 중에 다른 탭을 누르면 오버레이 닫고 해당 탭으로 이동
                overlayUserId = nil
                // #region agent log
                let payload: [String: Any] = [
                    "sessionId": "debug-session",
                    "runId": "pre-fix-2",
                    "hypothesisId": "H1",
                    "location": "RootTabView.swift:onChange(selectedTab)",
                    "message": "Tab changed",
                    "data": ["from": String(describing: oldValue), "to": String(describing: newValue)],
                    "timestamp": Date().timeIntervalSince1970
                ]
                
                if let url = URL(string: "http://127.0.0.1:7242/ingest/f0d53358-e857-43b6-9baf-1b348ed6f40f"),
                   let body = try? JSONSerialization.data(withJSONObject: payload) {
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = body
                    
                    URLSession.shared.dataTask(with: request) { _, _, _ in
                        // fire-and-forget
                    }.resume()
                }
                // #endregion
            }
            // 최상위 ZStack에서 팝업을 띄워 노치와 탭바를 모두 덮어준다
            if homeViewModel.activeFullSheet == .reflection {
                if let info = homeViewModel.journeyInfo,
                   let progressId = homeViewModel.reflectionProgressId {
                    ReflectionPopupView(
                        viewModel: ReflectionViewModel(
                            loopId: info.loopId,
                            currentDay: info.currentDay,
                            goalTitle: homeViewModel.goalTitle,
                            progressId: progressId
                        ),
                        isPresented: Binding(
                            get: { homeViewModel.activeFullSheet == .reflection },
                            set: { if !$0 { homeViewModel.activeFullSheet = nil } }
                        ),
                        onSaved: {
                            homeViewModel.markReflectionSaved()
                        }
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
