// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftShout",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftShout",
            targets: ["SwiftShout"],
        ),
    ],
    targets: [
        // https://theswiftdev.com/how-to-use-c-libraries-in-swift/
        // https://docs.swift.org/swiftpm/documentation/packagemanagerdocs/examplesystemlibrarypkgconfig/
        // https://docs.swift.org/swiftpm/documentation/packagemanagerdocs/addingsystemlibrarydependency/
        .systemLibrary(
            name: "CShout",
            pkgConfig: "shout",
            providers: [
                .brew(["libshout"]),
                .apt(["libshout-dev"])
            ]
        ),
        .target(
            name: "SwiftShout",
            dependencies: ["CShout"]
        ),
        .testTarget(
            name: "SwiftShoutTests",
            dependencies: [
                "SwiftShout",
                "CShout"
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
