// swift-tools-version:4.2

import PackageDescription

let package = Package(
  name: "SwiftPhoenixClient",
  dependencies: [
    .package(url: "https://github.com/vapor/websocket-kit", from: "1.1.2")
  ],
  targets: [
    .target(
      name: "SwiftPhoenixClient",
      dependencies: ["WebSocket"],
      path: "Sources"
    ),
  ]
)
