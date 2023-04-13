// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "PenguinKit",
  defaultLocalization: "en",
  platforms: [
    .macOS(.v13),
    .iOS("16.2"),
  ],
  products: [
    .library(
      name: "PenguinKit",
      targets: ["PenguinKit"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/alexisakers/HTMLString", .upToNextMajor(from: "6.0.0")),
    .package(url: "https://github.com/apple/swift-algorithms", .upToNextMajor(from: "1.0.0")),
    .package(url: "https://github.com/apple/swift-collections", branch: "release/1.1"),
    .package(url: "https://github.com/apple/swift-format", .upToNextMajor(from: "508.0.0")),
    .package(url: "https://github.com/tonyarnold/KeychainAccess", branch: "fix-macos-10-11-warning"),
    .package(url: "https://github.com/onevcat/Kingfisher", branch: "master"),
    .package(url: "https://github.com/stleamist/BetterSafariView", .upToNextMajor(from: "2.0.0")),
    .package(url: "https://github.com/zunda-pixel/AttributedText", .upToNextMajor(from: "2.0.0")),
    .package(url: "https://github.com/zunda-pixel/ChatBubble", .upToNextMajor(from: "1.0.0")),
    .package(url: "https://github.com/zunda-pixel/LicenseView", .upToNextMajor(from: "1.0.0")),
    .package(url: "https://github.com/zunda-pixel/Node", .upToNextMajor(from: "1.0.0")),
    .package(url: "https://github.com/zunda-pixel/Sweet", .upToNextMajor(from: "2.3.3")),
  ],
  targets: [
    .target(
      name: "PenguinKit",
      dependencies: [
        .product(name: "Algorithms", package: "swift-algorithms"),
        .product(name: "AttributedText", package: "AttributedText"),
        .product(name: "BetterSafariView", package: "BetterSafariView"),
        .product(name: "ChatBubble", package: "ChatBubble"),
        .product(name: "HTMLString", package: "HTMLString"),
        .product(name: "KeychainAccess", package: "KeychainAccess"),
        .product(name: "Kingfisher", package: "Kingfisher"),
        .product(name: "LicenseView", package: "LicenseView"),
        .product(name: "Node", package: "Node"),
        .product(name: "OrderedCollections", package: "swift-collections"),
        .product(name: "Sweet", package: "Sweet"),
      ],
      path: "Sources"
    )
  ]
)
