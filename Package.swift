// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ServiceProvider",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ServiceProvider",
            targets: ["ServiceProvider"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", "3.2.0"..."4.1.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift", from: "5.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ServiceProvider",
            dependencies: [
                "RxSwift", "KeychainAccess", "RxCocoa"
        ]),
        .testTarget(
            name: "ServiceProviderTests",
            dependencies: ["ServiceProvider"]),
    ]
)
