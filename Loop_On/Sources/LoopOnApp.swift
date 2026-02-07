import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct LOOPONApp: App {
    @State private var isFinishedSplash = false
    @State private var router = NavigationRouter()
    @State private var session = SessionStore()
    @State private var signUpFlowStore = SignUpFlowStore()

    init() {
        if let appKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] as? String,
           !appKey.isEmpty {
            KakaoSDK.initSDK(appKey: appKey)
        } else {
            // TODO: KAKAO_NATIVE_APP_KEY 설정 후 로그 제거
            print("KAKAO_NATIVE_APP_KEY가 없습니다.")
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if isFinishedSplash {
                    RootView()
                        .environment(router)
                        .environment(session)
                        .environment(signUpFlowStore)
                } else {
                    SplashView(isFinishedSplash: $isFinishedSplash)
                }
            }
            .onOpenURL { url in
                if AuthApi.isKakaoTalkLoginUrl(url) {
                    _ = AuthController.handleOpenUrl(url: url)
                }
            }
        }
    }
}
