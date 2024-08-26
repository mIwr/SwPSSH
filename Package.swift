
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwPSSH",
    platforms: [
        .macOS(.v10_13), .macCatalyst(.v13), .iOS(.v11), .tvOS(.v11), .watchOS(.v5), .visionOS(.v1) 
    ],
    products: [
        .library(
            name: "SwPSSH",
            targets: ["SwPSSH"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.27.1"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.8.3")
    ],
    targets: [
        .target(name: "SwPSSH", dependencies: [
            .product(name: "SwiftProtobuf", package: "swift-protobuf"),
            .product(name: "CryptoSwift", package: "CryptoSwift")
        ], resources: [.copy("PrivacyInfo.xcprivacy")]),
        .testTarget(name: "SwPSSHTests", dependencies: ["SwPSSH"]),
    ],
    swiftLanguageVersions: [.v5]
)
