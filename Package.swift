// swift-tools-version:5.1

import Foundation
import PackageDescription

let testing = ProcessInfo.processInfo.environment["TEST"] == "1"

let testPackages: [Package.Dependency] =
    testing
        ? [
            .package(url: "https://github.com/Quick/Quick.git", .upToNextMinor(from: "2.1.0")),
            .package(url: "https://github.com/Quick/Nimble.git", .upToNextMinor(from: "8.0.5")),
        ]
        : []

let testTargets: [Target.Dependency] = testing ? ["Quick", "Nimble"] : []

let package = Package(
    name: "Blueprint",
    products: [
        .library(name: "Blueprint", targets: ["Blueprint"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMinor(from: "5.1.0")),
        .package(url: "https://github.com/mitsuse/domain.git", .upToNextMinor(from: "0.3.0")),
    ] + testPackages,
    targets: [
        .target(name: "Blueprint", dependencies: ["RxSwift", "Domain"]),
        .testTarget(name: "BlueprintTests", dependencies: ["Blueprint"] + testTargets),
    ]
)
