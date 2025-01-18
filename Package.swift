// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(macOS)
let platforms: [PackageDescription.SupportedPlatform] = [.macOS(.v13)]
#elseif os(iOS)
let platforms: [PackageDescription.SupportedPlatform] = [.iOS(.v18)]
#else
let platforms: [PackageDescription.SupportedPlatform]? = nil
#endif

let package = Package(
  name: "PasskeyService",
  platforms: platforms,
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "PasskeyService",
      targets: ["PasskeyService"]),
    .library(
      name: "PasskeyService-ios",
      targets: ["PasskeyService-ios"]),
  ],
  dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.110.1"),
    .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
    .package(url: "https://github.com/swift-server/swift-webauthn.git", from: "1.0.0-alpha.2"),
    .package(url: "https://github.com/vapor/redis.git", from: "4.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "PasskeyService",
      dependencies: [
        .product(name: "Fluent", package: "fluent"),
        .product(name: "Vapor", package: "vapor"),
        .product(name: "WebAuthn", package: "swift-webauthn"),
        .product(name: "Redis", package: "redis"),
      ]
    ),
    .target(
      name: "PasskeyService-ios"),
    .testTarget(
      name: "PasskeyServiceTests",
      dependencies: ["PasskeyService"]
    ),
  ]
)
