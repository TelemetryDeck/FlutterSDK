// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "telemetrydecksdk",
    platforms: [
        .macOS("10.15")
    ],
    products: [
        .library(name: "telemetrydecksdk", targets: ["telemetrydecksdk"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/TelemetryDeck/SwiftSDK", .upToNextMajor(from: "2.11.0"))
    ],
    targets: [
        .target(
            name: "telemetrydecksdk",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "TelemetryDeck", package: "SwiftSDK")
            ]
        )
    ]
)
