import ProjectDescription

let project = Project(
    name: "Loop_On",
    targets: [
        .target(
            name: "Loop_On",
            destinations: .iOS,
            product: .app,
            bundleId: "com.loopon.LoopOn",
            infoPlist: .extendingDefault(
                with: [
	  	    "BASE_URL": "$(BASE_URL)",
                    "KAKAO_NATIVE_APP_KEY": "$(KAKAO_NATIVE_APP_KEY)",
                    "LSApplicationQueriesSchemes": [
                        "kakaokompassauth",
                        "kakaolink"
                    ],
                    "CFBundleURLTypes": [
                        [
                            "CFBundleURLName": "kakao",
                            "CFBundleURLSchemes": ["kakao$(KAKAO_NATIVE_APP_KEY)"]
                        ]
                    ],
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "UIAppFonts": [
                        "Font/Pretendard-Light.otf",
                        "Font/Pretendard-ExtraLight.otf",
                        "Font/Pretendard-Thin.otf",
                        "Font/Pretendard-Bold.otf",
                        "Font/Pretendard-SemiBold.otf",
                        "Font/Pretendard-Medium.otf",
                        "Font/Pretendard-Black.otf",
                        "Font/Pretendard-Regular.otf",
                        "Font/Pretendard-ExtraBold.otf",
                    ],
                    // 카메라 및 사진첩 권한 설정
                    "NSCameraUsageDescription": "루틴 인증 사진 촬영을 위해 카메라 권한이 필요합니다.",
                    "NSPhotoLibraryUsageDescription": "사진 추가를 위해 갤러리 접근 권한이 필요합니다.",
                    "NSPhotoLibraryAddUsageDescription": "사진 추가를 위해 갤러리 접근 권한이 필요합니다."
                ]
            ), // infoPlist 괄호 닫기
	    sources: ["Loop_On/Sources/**"],
            resources: ["Loop_On/Resources/**"],
            entitlements: .file(path: .relativeToRoot("Loop_On/Loop_On.entitlements")),
            dependencies: [
	    	.external(name: "Alamofire"),
                .external(name: "Kingfisher"),
                .external(name: "Moya"),
		.external(name: "Lottie"),
		// 카카오 SDK
                .external(name: "KakaoSDKCommon"),
                .external(name: "KakaoSDKAuth"),
                .external(name: "KakaoSDKUser"),
	    ],
	    settings: .settings(
        	configurations: [
            	    .debug(name: "Debug", xcconfig: "Loop_On/Sources/Secret.xcconfig"),
            	    .release(name: "Release", xcconfig: "Loop_On/Sources/Secret.xcconfig")
        	]
    	   )
        ),
        .target(
            name: "Loop_OnTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.Loop-OnTests",
            infoPlist: .default,
	    sources: ["Loop_On/Tests/**"],
            dependencies: [.target(name: "Loop_On")]
        ),
    ],
    additionalFiles: [
        "Loop_On/Sources/Secret.xcconfig",
	"Loop_On/Sources/Loading/Loading 51 _ Monoplane.json",
	"Loop_On/Sources/Loading/TriPriend.json"
    ]
)
