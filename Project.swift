import ProjectDescription

let project = Project(
    name: "Loop_On",
    targets: [
        .target(
            name: "Loop_On",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.Loop-On",
            infoPlist: .extendingDefault(
                with: [
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
                ]
            ),
	    sources: ["Loop_On/Sources/**"],
        resources: ["Loop_On/Resources/**"],
            
	   // buildableFolders: [ "Loop_On/Sources", "Loop_On/Resources"],

            dependencies: [
	    	.external(name: "Alamofire"),
                .external(name: "Kingfisher"),
                .external(name: "Moya"),

		// 카카오 SDK
                .external(name: "KakaoSDKCommon"),
                .external(name: "KakaoSDKAuth"),
                .external(name: "KakaoSDKUser"),
	    ]
        ),
        .target(
            name: "Loop_OnTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.Loop-OnTests",
            infoPlist: .default,
	    sources: ["Loop_On/Tests/**"],
            // buildableFolders: ["Loop_On/Tests"],
            dependencies: [.target(name: "Loop_On")]
        ),
    ]
)
