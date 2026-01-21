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

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            // 시작 화면 분기 (Splash 다음에 여기로 들어옴)
            Group {
                if session.hasLoggedInBefore {
//                    HomeView()
                    RootTabView()
                } else {
//                    AuthView()
                    
                    RootTabView()
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

                case let .app(.detail(title)):
                    // DetailView(title: title)   임시로 Text(title)로 대체
                    Text(title)

                case let .app(.profile(userID)):
                    // ProfileView(userID: userID) 임시로 Text("\(userID)")로 대체
                    Text("\(userID)")
                }
            }
        }
    }
}

