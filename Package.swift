// swift-tools-version:4.0

import Foundation
import PackageDescription

let testing = ProcessInfo.processInfo.environment["TEST"] == "1"

let testPackages: [Package.Dependency] =
    testing
        ? [
            .package(url: "https://github.com/Quick/Quick.git", .upToNextMinor(from: "1.2.0")),
            .package(url: "https://github.com/Quick/Nimble.git", .upToNextMinor(from: "7.0.2")),
        ]
        : []

let testTargets: [Target.Dependency] = testing ? ["Quick", "Nimble"] : []

let package = Package(
    name: "Blueprint",
    products: [
        .library(name: "Blueprint", targets: ["Blueprint"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMinor(from: "4.3.0")),
        .package(url: "https://github.com/mitsuse/domain.git", .upToNextMinor(from: "0.2.1")),
    ] + testPackages,
    targets: [
        .target(name: "Blueprint", dependencies: ["RxSwift", "Domain"]),
        .testTarget(name: "BlueprintTests", dependencies: ["Blueprint"] + testTargets),
    ]
)
