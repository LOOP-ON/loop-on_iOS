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
                ]
            ),
            buildableFolders: [
                "Loop_On/Sources",
                "Loop_On/Resources",
            ],
            dependencies: []
        ),
        .target(
            name: "Loop_OnTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.Loop-OnTests",
            infoPlist: .default,
            buildableFolders: [
                "Loop_On/Tests"
            ],
            dependencies: [.target(name: "Loop_On")]
        ),
    ]
)
