//
//  RootView.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//
import SwiftUI
import Combine

struct RootView: View {
    @Environment(NavigationRouter.self) private var router
    @Environment(SessionStore.self) private var session

    @StateObject private var homeViewModel = HomeViewModel()
    @State private var signUpFlowStore = SignUpFlowStore()
    @State private var isCheckingCurrentJourney = false
    @State private var hasCurrentJourney = false
    @State private var hasResolvedEntry = false
    private let homeNetworkManager = DefaultNetworkManager<HomeAPI>()

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            // 시작 화면 분기 (Splash 다음에 여기로 들어옴)
            Group {
                if session.hasValidToken {
                    if !hasResolvedEntry || isCheckingCurrentJourney {
                        ProgressView("여정 정보를 확인하는 중...")
                    } else if hasCurrentJourney || session.isOnboardingCompleted {
                        RootTabView()
                            .environmentObject(homeViewModel)
                    } else {
                        IntroView()
                            .navigationBarBackButtonHidden(true)
                    }
//                    HomeView()
//                    온보딩 스킵해서 테스트 할 경우 여기 사용
//                    RootTabView()
//                        .environmentObject(homeViewModel)
                } else {
                    AuthView()
                    // RootTabView() 회원가입 api 연동 기간 동안 잠시 주석 처리
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .auth(.login):
                    AuthView()
                
                case .auth(.setProfile):
                    ProfileView()

                case .auth(.signUp):
                    SignUpView()
                    
                case .auth(.findPassword):
                    FindPasswordView()

                case .app(.home):
                    HomeView()

                case .app(.passport):
                    PassportView()
                        .navigationBarBackButtonHidden(true)
                
                case let .app(.routineCoach(routines, goal, category, selectedInsights, showContinuationPopup)):
                    RoutineCoachView(
                        routines: routines,
                        goal: goal,
                        category: category,
                        selectedInsights: selectedInsights,
                        showContinuationPopup: showContinuationPopup
                    )
                        .toolbar(.hidden, for: .tabBar)
                        .navigationBarBackButtonHidden(true)
                        .ignoresSafeArea(.all)

                case .app(.settings):
                    SettingsView()
                        .navigationBarBackButtonHidden(true)

                case .app(.account):
                    AccountView()
                        .navigationBarBackButtonHidden(true)

                case .app(.notifications):
                    NotificationsView()
                        .navigationBarBackButtonHidden(true)

                case .app(.system):
                    SystemView()
                        .navigationBarBackButtonHidden(true)

                case .app(.goalSelect):
                    GoalSelectView()
                        .navigationBarBackButtonHidden(true)
                
                case .app(.onBoarding):
                    IntroView()
                        .navigationBarBackButtonHidden(true)

                case let .app(.goalInput(category)):
                    GoalInputView(category: category)

                case let .app(.insightSelect(goalText, category, insights)):
                    InsightSelectView(goalText: goalText, category: category, insights: insights)

                case let .app(.detail(title)):
                    // DetailView(title: title)   임시로 Text(title)로 대체
                    Text(title)

                case let .app(.expeditionDetail(expeditionId, expeditionName, isPrivate, isJoined, isAdmin, canJoin)):
                    ChallengeExpeditionDetailView(
                        expeditionId: expeditionId,
                        expeditionName: expeditionName,
                        isPrivate: isPrivate,
                        isJoined: isJoined,
                        isAdmin: isAdmin,
                        canJoin: canJoin
                    )
                    .navigationBarBackButtonHidden(true)

                case let .app(.profile(userID)):
                    // 타인 프로필: 뒤로가기는 커스텀 헤더, 하단 탭바 유지
                    PersonalProfileView(isOwnProfile: false)
                        .navigationBarBackButtonHidden(true)
                        .toolbar(.visible, for: .tabBar)
                }
            }
        }
        .onAppear {
            session.validateSessionAtLaunchIfNeeded()
            resolveEntryRouteIfNeeded(force: true)
        }
        .onChange(of: session.hasValidToken) { _, _ in
            resolveEntryRouteIfNeeded(force: true)
        }
        .onReceive(NotificationCenter.default.publisher(for: .authenticationRequired)) { _ in
            session.logout()
            router.reset()
        }
        .environment(signUpFlowStore)
        .environmentObject(homeViewModel)
    }

    private func resolveEntryRouteIfNeeded(force: Bool = false) {
        guard session.hasValidToken else {
            hasResolvedEntry = true
            hasCurrentJourney = false
            isCheckingCurrentJourney = false
            return
        }

        if isCheckingCurrentJourney && !force { return }

        isCheckingCurrentJourney = true
        hasResolvedEntry = false

        homeNetworkManager.requestStatusCode(target: .fetchCurrentJourney) { result in
            DispatchQueue.main.async {
                isCheckingCurrentJourney = false
                hasResolvedEntry = true

                switch result {
                case .success:
                    hasCurrentJourney = true
                    session.completeOnboarding()
                    homeViewModel.fetchHomeData()

                case .failure(let error):
                    hasCurrentJourney = false

                    if case .unauthorized = error {
                        session.logout()
                        router.reset()
                    } else if case let .serverError(statusCode, _) = error, statusCode == 500 {
                        session.logout()
                        router.reset()
                    } else if case let .serverError(statusCode, _) = error, statusCode == 404 {
                        // 404는 "현재 진행 여정 없음"일 수 있음.
                        // 로그인 직후에는 온보딩으로, 앱 재실행 자동진입 시에는 세션 정리 후 로그인으로 보낸다.
                        if session.isLoggedIn {
                            session.isOnboardingCompleted = false
                        } else {
                            session.logout()
                            router.reset()
                        }
                    }
                }
            }
        }
    }
}
