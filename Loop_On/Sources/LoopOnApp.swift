import SwiftUI

@main
struct LOOPONApp: App {
    @State private var isFinishedSplash = false
    @State private var router = NavigationRouter()
    @State private var session = SessionStore()
    @State private var signUpFlowStore = SignUpFlowStore()

    var body: some Scene {
        WindowGroup {
            if isFinishedSplash {
                RootView()
                    .environment(router)
                    .environment(session)
                    .environment(signUpFlowStore)
            } else {
                SplashView(isFinishedSplash: $isFinishedSplash)
            }
        }
    }
}
