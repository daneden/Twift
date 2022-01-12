// swift-tools-version:5.5

import PackageDescription

let package = Package(
  name: "Twift",
  platforms: [
    .macOS(.v12), .iOS(.v15)
  ],
  products: [
    .library(name: "Twift", targets: ["Twift"])
  ],
  targets: [
    .target(
      name: "Twift",
      path: "Sources"),
    .testTarget(
      name: "TwiftTests",
      dependencies: ["Twift"]),
  ]
)
