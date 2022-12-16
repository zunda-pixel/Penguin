// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Format",
  dependencies: [
    .package(url: "https://github.com/apple/swift-format", branch: "main")
  ]
)
