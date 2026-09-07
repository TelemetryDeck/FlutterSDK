// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "telemetrydecksdk",
    platforms: [
        .iOS("15.0"),
        .macOS("12.0")
    ],
    products: [
        .library(name: "telemetrydecksdk", targets: ["telemetrydecksdk"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/TelemetryDeck/SwiftSDK", exact: "3.0.0-beta.5")
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
