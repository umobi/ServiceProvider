// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ServiceProvider",
    platforms: [.iOS(.v10), .tvOS(.v10), .watchOS(.v4), .macOS(.v10_13)],
    products: [
        .library(
            name: "ServiceProvider",
            targets: ["ServiceProvider"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/ReactiveX/RxSwift", .upToNextMajor(from: "5.0.0")),
    ],
    targets: [
        .target(
            name: "ServiceProvider",
            dependencies: [
                .product(name: "RxCocoa", package: "RxSwift"),
                "RxSwift", "KeychainAccess"
            ]
        ),
        .testTarget(
            name: "ServiceProviderTests",
            dependencies: ["ServiceProvider"]),
    ]
)
