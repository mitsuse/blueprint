// swift-tools-version:5.3

import Foundation
import PackageDescription

let package = Package(
    name: "Blueprint",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "Blueprint", targets: ["Blueprint"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMinor(from: "6.6.0")),
        .package(name: "Domain", url: "https://github.com/mitsuse/domain.git", .upToNextMinor(from: "0.6.0")),
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMinor(from: "7.4.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMinor(from: "13.2.0")),
    ],
    targets: [
        .target(name: "Blueprint", dependencies: ["RxSwift", "Domain"]),
        .testTarget(name: "BlueprintTests", dependencies: ["Blueprint", "Quick", "Nimble"]),
    ]
)
