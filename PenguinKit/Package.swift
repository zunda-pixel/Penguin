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
    .package(url: "https://github.com/zunda-pixel/Node", .upToNextMajor(from: "1.0.0")),
    .package(url: "https://github.com/zunda-pixel/LicenseView", .upToNextMajor(from: "1.0.0")),
    .package(url: "https://github.com/apple/swift-algorithms", .upToNextMajor(from: "1.0.0")),
    .package(url: "https://github.com/apple/swift-format", branch: "main"),
    .package(url: "https://github.com/apple/swift-collections", .upToNextMajor(from: "1.0.0")),
    .package(url: "https://github.com/zunda-pixel/Sweet", branch: "main"),
    .package(url: "https://github.com/onevcat/Kingfisher", .upToNextMajor(from: "7.0.0")),
    .package(url: "https://github.com/zunda-pixel/ChatBubble", .upToNextMajor(from: "1.0.0")),
    .package(url: "https://github.com/zunda-pixel/AttributedText", .upToNextMajor(from: "2.0.0")),
    .package(url: "https://github.com/alexisakers/HTMLString", .upToNextMajor(from: "6.0.0")),
    .package(url: "https://github.com/stleamist/BetterSafariView", .upToNextMajor(from: "2.0.0")),
    .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", .upToNextMajor(from: "4.2.2")),
    .package(url: "https://github.com/firebase/firebase-ios-sdk", .upToNextMajor(from: "10.4.0")),
  ],
  targets: [
    .target(
      name: "PenguinKit",
      dependencies: [
        .product(name: "Node", package: "Node"),
        .product(name: "LicenseView", package: "LicenseView"),
        .product(name: "Algorithms", package: "swift-algorithms"),
        .product(name: "OrderedCollections", package: "swift-collections"),
        .product(name: "Sweet", package: "Sweet"),
        .product(name: "Kingfisher", package: "Kingfisher"),
        .product(name: "ChatBubble", package: "ChatBubble"),
        .product(name: "AttributedText", package: "AttributedText"),
        .product(name: "HTMLString", package: "HTMLString"),
        .product(name: "BetterSafariView", package: "BetterSafariView"),
        .product(name: "KeychainAccess", package: "KeychainAccess"),
        .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
      ],
      path: "Sources"
    )
  ]
)
