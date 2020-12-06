// swift-tools-version:5.3

import Foundation
import PackageDescription

let package = Package(
    name: "Blueprint",
    products: [
        .library(name: "Blueprint", targets: ["Blueprint"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMinor(from: "5.1.0")),
        .package(name: "Domain", url: "https://github.com/mitsuse/domain.git", .upToNextMinor(from: "0.3.0")),
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMinor(from: "3.0.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMinor(from: "9.0.0")),
    ],
    targets: [
        .target(name: "Blueprint", dependencies: ["RxSwift", "Domain"]),
        .testTarget(name: "BlueprintTests", dependencies: ["Blueprint", "Quick", "Nimble"]),
    ]
)
