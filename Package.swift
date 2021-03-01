// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KeychainOTPKit",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "KeychainOTPKit",
            targets: ["KeychainOTPKit"]),
    ],
    dependencies: [
         .package(url: "https://github.com/belous/OTPKit.git", from: "0.2.1"),
    ],
    targets: [
        .target(
            name: "KeychainOTPKit",
            dependencies: ["OTPKit"]),
        .testTarget(
            name: "KeychainOTPKitTests",
            dependencies: ["KeychainOTPKit", "OTPKit"]),
    ]
)
