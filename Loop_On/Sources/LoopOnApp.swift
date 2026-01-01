import SwiftUI

@main
struct LOOPONApp: App {
    @State private var isFinishedSplash = false
    @State private var router = NavigationRouter()
    @State private var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            if isFinishedSplash {
                RootView()
                    .environment(router)
                    .environment(session)
            } else {
                SplashView(isFinishedSplash: $isFinishedSplash)
            }
        }
    }
}
