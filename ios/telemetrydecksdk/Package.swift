// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "telemetrydecksdk",
  platforms: [
    .iOS("12.0"),
    .macOS("10.14"),
  ],
  products: [
    .library(name: "telemetrydecksdk", targets: ["telemetrydecksdk"])
  ], dependencies: [
    .package(url: "https://github.com/TelemetryDeck/SwiftSDK", from: "2.9.1")
  ],
  targets: [
    .target(
      name: "telemetrydecksdk",
      dependencies: [
        .product(name: "TelemetryDeck", package: "SwiftSDK")
      ],
      resources: [
        .process("PrivacyInfo.xcprivacy")
      ]
    )
  ]
)
