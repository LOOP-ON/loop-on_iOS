//
//  RootView.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//
import SwiftUI

struct RootView: View {
    @Environment(NavigationRouter.self) private var router
    @Environment(SessionStore.self) private var session

    @StateObject private var homeViewModel = HomeViewModel()
    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            // 시작 화면 분기 (Splash 다음에 여기로 들어옴)
            Group {
                if session.hasValidToken && session.isOnboardingCompleted {
//                    HomeView()
                    RootTabView()
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
                
                case .app(.routineCoach):
                    RoutineCoachView()
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

                case let .app(.profile(userID)):
                    PersonalProfileView()
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
        .environmentObject(homeViewModel)
    }
}

