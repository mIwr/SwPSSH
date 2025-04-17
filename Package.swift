
// swift-tools-version: 5.9
import PackageDescription

let protobufMinVersion: Version = "1.29.0"

#if targetEnvironment(simulator) || targetEnvironment(macCatalyst) || os(macOS) || os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)
//Exclude CryptoSwift package (used built-in CommonCrypto)
let dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-protobuf.git", from: protobufMinVersion)
]
let mainTargetDependencies: [Target.Dependency] = [
    .product(name: "SwiftProtobuf", package: "swift-protobuf"),
]
#else
let dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-protobuf.git", from: protobufMinVersion),
    .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.8.4")
]
let mainTargetDependencies: [Target.Dependency] = [
    .product(name: "SwiftProtobuf", package: "swift-protobuf"),
    .product(name: "CryptoSwift", package: "CryptoSwift")
]
#endif

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
    dependencies: dependencies,
    targets: [
        .target(name: "SwPSSH", dependencies: mainTargetDependencies, resources: [.copy("PrivacyInfo.xcprivacy")]),
        .testTarget(name: "SwPSSHTests", dependencies: ["SwPSSH"]),
    ],
    swiftLanguageVersions: [.v5]
)


