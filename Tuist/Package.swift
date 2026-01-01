// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [
		"Alamofire": .framework
	]
    )
#endif

let package = Package(
    name: "Loop_On",
    dependencies: [
	// 카카오 SDK
        .package(url: "https://github.com/kakao/kakao-ios-sdk", from: "2.22.5"),
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
        .package(url: "https://github.com/guoyingtao/Mantis.git", from: "2.27.0"),
	
	//Alamofire
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.10.0"),
	.package(url: "https://github.com/kakao/kakao-ios-sdk", .upToNextMajor(from: "2.25.0")),
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "8.6.1")),
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.3"))
    ]
)
