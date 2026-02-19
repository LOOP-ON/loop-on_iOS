import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import UserNotifications

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

        UNUserNotificationCenter.current().delegate = NotificationCenterDelegate.shared
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

final class NotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationCenterDelegate()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound, .badge])
    }
}
