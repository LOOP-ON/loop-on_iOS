import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct LOOPONApp: App {
    @State private var isFinishedSplash = false
    @State private var router = NavigationRouter()
    @State private var session = SessionStore()

    init() {
        #if DEBUG
        if let url = Bundle.main.infoDictionary?["BASE_URL"] as? String {
            print("📍 BASE_URL(앱이 사용 중): [\(url)]")
        } else {
            print("📍 BASE_URL이 Info.plist에 없음 (xcconfig 적용 여부 확인)")
        }
        #endif
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
